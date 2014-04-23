{*------------------------------------------------------------------------------
  Groups Support
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth
------------------------------------------------------------------------------}
{$I compiler.inc}
unit Components.GameCore.Groups;

interface

uses
  Misc.Containers,
  Framework.Base,
  Components.Shared,
  Components.NetworkCore.Packet,
  Components.GameCore.WowPlayer;

type
  YGroupPlayerSet = array[0..4] of YGaPlayer;
  //YLootType = (ltUnknwon);  What are the loot types?

  YGaParty = class(TInterfacedObject)
    private
      fGID: UInt32;
      fMemberLimit: Int32;
      fMemberCount: Int32;
      fLeader: YGaPlayer;
      fLooter: YGaPlayer;
      fSubGroups: array of YGroupPlayerSet;
      fSubGroupLeaders: array of YGaPlayer;
      fLookupTree: TPtrBinaryTree;
      fOccupationMask: array of UInt8;
      fLootThreshold: UInt16;
      fLootType: UInt8;
      //fLootType: YLootType;

      procedure DispatchUpdates;
      
      procedure OccupationIndexToSubGroupIndices(Bit: Int32; out SubGroup: Int32;
        out Index: Int32); inline;

      procedure SetLeader(Player: YGaPlayer);
      procedure SetLooter(Player: YGaPlayer);

      function BuildGroupDestroyed: YNwServerPacket;
      function BuildGroupListEmpty: YNwServerPacket;
    protected
      constructor CreateInternal(GID: UInt32; SubGroups: Int32);

      class function GetGroupType: Int32; virtual;
    public
      constructor Create(GID: UInt32; Leader: YGaPlayer);
      destructor Destroy; override;

      procedure DispatchPacket(Pkt: YNwServerPacket; Ignore: YGaPlayer);

      procedure AddMember(Player: YGaPlayer);
      procedure RemoveMember(Player: YGaPlayer);
      function IsMember(Player: YGaPlayer): Boolean; 

      property MaximumMembers: Int32 read fMemberLimit;
      property MemberCount: Int32 read fMemberCount;
      property Leader: YGaPlayer read fLeader write SetLeader;
      property Looter: YGaPlayer read fLooter write SetLooter;

      property GroupType: Int32 read GetGroupType;
  end;

  YGaRaid = class(YGaParty)
    protected
      class function GetGroupType: Int32; override;
    public
      constructor Create(GID: UInt32; Leader: YGaPlayer);
      constructor CreateFromParty(GID: UInt32; Party: YGaParty);
  end;

implementation

uses
  Components.NetworkCore.Opcodes,
  Components.Interfaces,
  Misc.Miscleanous;

{ YGaParty }

constructor YGaParty.Create(GID: UInt32; Leader: YGaPlayer);
begin
  CreateInternal(GID, 1);
  if Assigned(Leader) then
  begin
    AddMember(Leader);
  end;
end;

constructor YGaParty.CreateInternal(GID: UInt32; SubGroups: Int32);
begin
  inherited Create;

  Assert(SubGroups > 0);
  
  fGID := GID;
  fMemberLimit := SubGroups * 5;
  SetLength(fOccupationMask, DivModPowerOf2Inc(fMemberLimit, 3));
  SetLength(fSubGroups, SubGroups);
  fLookupTree := TPtrBinaryTree.Create;
end;

destructor YGaParty.Destroy;
begin
  fLookupTree.Free;

  inherited Destroy;
end;

procedure YGaParty.DispatchPacket(Pkt: YNwServerPacket; Ignore: YGaPlayer);
var
  iIdx: Int32;
  cPlr: YGaPlayer;
begin
  for iIdx := 0 to High(fSubGroups) do
  begin
    for cPlr in fSubGroups[iIdx] do
    begin
      if Assigned(cPlr) and (cPlr <> Ignore) then
      begin
        cPlr.SendPacket(Pkt);
      end;
    end;
  end;
end;

procedure YGaParty.DispatchUpdates;
var
  cPkt: YNwServerPacket;
  cPlr, cMember: YGaPlayer;
  iI, iJ, iK, iM: Int32;
begin
  for iI := 0 to High(fSubGroups) do
  begin
    for iJ := 0 to 4 do
    begin
      cPlr := fSubGroups[iI, iJ];
      if Assigned(cPlr) then
      begin
        cPkt := YNwServerPacket.Initialize(SMSG_GROUP_LIST);
        try
          cPkt.AddUInt8(GroupType);
          cPkt.AddUInt8(0); { ??? }
          cPkt.AddUInt8(fGID);
          cPkt.AddUInt32(fMemberCount-1); { We exclude self from the list }
          for iK := 0 to High(fSubGroups) do
          begin
            for iM := 0 to 4 do
            begin
              cMember := fSubGroups[iK, iM];
              if Assigned(cMember) and (cMember <> cPlr) then
              begin
                cPkt.AddString(cMember.Name);
                cPkt.AddUInt64(cMember.GUIDFull);
                cPkt.AddUInt8(1); { ??? }
                cPkt.AddUInt8(iK); { SubgroupID }
              end;
            end;
          end;

          if fLeader <> nil then
          begin
            cPkt.AddUInt64(fLeader.GUIDFull);
          end else
          begin
            cPkt.JumpUInt64;
          end;

          cPkt.AddUInt8(fLootType);

          if fLooter <> nil then
          begin
            cPkt.AddUInt64(fLooter.GUIDFull);
          end else
          begin
            cPkt.JumpUInt64;
          end;

          cPkt.AddUInt16(fLootThreshold);

          {$IFDEF WOW_TBC}
          cPkt.JumpUInt64; { ??? }
          cPkt.JumpUInt64; { ??? }
          {$ENDIF}

          cPlr.SendPacket(cPkt);
        finally
          cPkt.Free;
        end;
      end;
    end;
  end;
end;

class function YGaParty.GetGroupType: Int32;
begin
  Result := 0;
end;

function YGaParty.IsMember(Player: YGaPlayer): Boolean;
begin
  Result := fLookupTree.Contains(Player);
end;

procedure YGaParty.OccupationIndexToSubGroupIndices(Bit: Int32; out SubGroup,
  Index: Int32);
begin
  SubGroup := DivMod(Bit, 5, Index);
end;

procedure YGaParty.RemoveMember(Player: YGaPlayer);
var
  iIdx, iIdx2: Int32;
  iBit: Int32;
  iSubGroup: Int32;
  iGroupIndex: Int32;
begin
  Assert(IsMember(Player));
  for iIdx := 0 to High(fSubGroups) do
  begin
    for iIdx2 := 0 to 4 do
    begin
      if fSubGroups[iIdx, iIdx2] = Player then
      begin
        fSubGroups[iIdx, iIdx2] := nil;
        ResetBit(@fOccupationMask, (iIdx * Length(fSubGroups)) + iIdx2);
        if Player = fLeader then
        begin
          iBit := SetBitScanForward(@fOccupationMask, 0, fMemberLimit -1);
          OccupationIndexToSubGroupIndices(iBit, iSubGroup, iGroupIndex);
          fLeader := fSubGroups[iSubGroup, iGroupIndex];
        end;
        Exit;
      end;
    end;
  end;
end;

function YGaParty.BuildGroupDestroyed: YNwServerPacket;
begin
  Result := YNwServerPacket.Initialize(SMSG_GROUP_DESTROYED, 0);
end;

function YGaParty.BuildGroupListEmpty: YNwServerPacket;
begin
  Result := YNwServerPacket.Initialize(SMSG_GROUP_LIST, 14);
  Result.Jump(14);
end;

procedure YGaParty.SetLeader(Player: YGaPlayer);
var
  cPkt: YNwServerPacket;
begin
  fLeader := Player;
  cPkt := YNwServerpacket.Initialize(SMSG_GROUP_SET_LEADER, Length(Player.Name) + 1);
  try
    cPkt.AddString(Player.Name);
    DispatchPacket(cPkt, nil);
  finally
    cPkt.Free;
  end;
  DispatchUpdates;
end;

procedure YGaParty.SetLooter(Player: YGaPlayer);
begin

end;

procedure YGaParty.AddMember(Player: YGaPlayer);
var
  iIdx: Int32;
  iSubGroup: Int32;
  iGroupIndex: Int32;
begin
  Assert(not IsMember(Player));
  if fMemberCount < fMemberLimit then
  begin
    if fMemberCount <> 0 then
    begin
      iIdx := ResetBitScanForward(@fOccupationMask, 0, fMemberLimit -1); { Find first free position }
      SetBit(@fOccupationMask, iIdx); { Mark as occupied }

      OccupationIndexToSubGroupIndices(iIdx, iSubGroup, iGroupIndex);
      fSubGroups[iSubGroup, iGroupIndex] := Player;
      Inc(fMemberCount);
    end else
    begin
      fLeader := Player;
      fSubGroups[0, 0] := Player;
      SetBit(@fOccupationMask, 0);
      fMemberCount := 1;
    end;
  end;
end;

{ YGaRaid }

constructor YGaRaid.Create(GID: UInt32; Leader: YGaPlayer);
begin
  CreateInternal(GID, 8);
  if Assigned(Leader) then
  begin
    AddMember(Leader);
  end;
end;

constructor YGaRaid.CreateFromParty(GID: UInt32; Party: YGaParty);
begin
  Create(GID, Party.Leader);
  fMemberCount := Party.MemberCount;
  fSubGroups[0] := Party.fSubGroups[0];
end;

class function YGaRaid.GetGroupType: Int32;
begin
  Result := 1;
end;

end.
