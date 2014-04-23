{$IFDEF PROFILE} {$O-} {$WARNINGS OFF} {$ENDIF }
{*------------------------------------------------------------------------------
  Generalized Container Info
  
  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://yawe.mcheats.net/index.php
  @Copyright YAWE Team
  @Author Seth, PavkaM
------------------------------------------------------------------------------}

{$I compiler.inc}
unit Bfg.Containers;

interface

uses
  Bfg.Containers.Interfaces,
  Bfg.Containers.ArrayList,
  Bfg.Containers.ByteBuffer,
  Bfg.Containers.CircularBuffer,
  Bfg.Containers.BinaryTrees,
  Bfg.Containers.LinkedLists,
  Bfg.Containers.Sets,
  Bfg.Containers.HashMap,
  Bfg.Containers.HashSets,
  Bfg.Containers.Stacks,
  Bfg.Containers.Queues,
  Bfg.Containers.StringList,
  Bfg.Containers.SortedMap{$IFNDEF PROFILE};{$ELSE}{},Profint;{$ENDIF}

type
  { Array lists }
  TArrayList = Bfg.Containers.ArrayList.TArrayList;
  TPtrArrayList = Bfg.Containers.ArrayList.TPtrArrayList;
  TStrArrayList = Bfg.Containers.ArrayList.TStrArrayList;
  TIntArrayList = Bfg.Containers.ArrayList.TIntArrayList;
  TIntfArrayList = Bfg.Containers.ArrayList.TIntfArrayList;

  { Byte buffer }
  TBufferSeekType = Bfg.Containers.ByteBuffer.TBufferSeekType;
  TByteBuffer = Bfg.Containers.ByteBuffer.TByteBuffer;

  { Circular buffer }
  TCircularBuffer = Bfg.Containers.CircularBuffer.TCircularBuffer;

  { Array sets }
  TArraySet = Bfg.Containers.Sets.TArraySet;
  TPtrArraySet = Bfg.Containers.Sets.TPtrArraySet;
  TStrArraySet = Bfg.Containers.Sets.TStrArraySet;
  TIntArraySet = Bfg.Containers.Sets.TIntArraySet;
  TIntfArraySet = Bfg.Containers.Sets.TIntfArraySet;

  { Sorted maps }
  TStrSortedMap = Bfg.Containers.SortedMap.TStrSortedMap;
  TIntSortedMap = Bfg.Containers.SortedMap.TIntSortedMap;

  { Hash maps }
  THashMap = Bfg.Containers.HashMap.THashMap;
  TPtrPtrHashMap = Bfg.Containers.HashMap.TPtrPtrHashMap;
  TStrHashMap = Bfg.Containers.HashMap.TStrHashMap;
  TStrStrHashMap = Bfg.Containers.HashMap.TStrStrHashMap;
  TStrIntHashMap = Bfg.Containers.HashMap.TStrIntHashMap;
  TStrPtrHashMap = Bfg.Containers.HashMap.TStrPtrHashMap;
  TStrIntfHashMap = Bfg.Containers.HashMap.TStrIntfHashMap;
  TIntHashMap = Bfg.Containers.HashMap.TIntHashMap;
  TIntIntHashMap = Bfg.Containers.HashMap.TIntIntHashMap;
  TIntPtrHashMap = Bfg.Containers.HashMap.TIntPtrHashMap;
  TIntfIntfHashMap = Bfg.Containers.HashMap.TIntfIntfHashMap;

  { Hash sets }
  TStrHashSet = Bfg.Containers.HashSets.TStrHashSet;
  TIntHashSet = Bfg.Containers.HashSets.TIntHashSet;
  TPtrHashSet = Bfg.Containers.HashSets.TPtrHashSet;
  THashSet = Bfg.Containers.HashSets.THashSet;

  { Stack }
  TIntfStack = Bfg.Containers.Stacks.TIntfStack;
  TStrStack = Bfg.Containers.Stacks.TStrStack;
  TPtrStack = Bfg.Containers.Stacks.TPtrStack;
  TStack = Bfg.Containers.Stacks.TStack;

  { Queue }
  TIntfQueue = Bfg.Containers.Queues.TIntfQueue;
  TStrQueue = Bfg.Containers.Queues.TStrQueue;
  TPtrQueue = Bfg.Containers.Queues.TPtrQueue;
  TQueue = Bfg.Containers.Queues.TQueue;

  { String Data List }
  TStringDataList = Bfg.Containers.StringList.TStringDataList;

  { Linked Lists }
  TStrLinkedList = Bfg.Containers.LinkedLists.TStrLinkedList;
  TIntfLinkedList = Bfg.Containers.LinkedLists.TIntfLinkedList;
  TPtrLinkedList = Bfg.Containers.LinkedLists.TPtrLinkedList;
  TLinkedList = Bfg.Containers.LinkedLists.TLinkedList;

  { Trees }
  TStrBinaryTree = Bfg.Containers.BinaryTrees.TStrBinaryTree;
  THashedStrBinaryTree = Bfg.Containers.BinaryTrees.THashedStrBinaryTree;
  TIntfBinaryTree = Bfg.Containers.BinaryTrees.TIntfBinaryTree;
  TPtrBinaryTree = Bfg.Containers.BinaryTrees.TPtrBinaryTree;
  TBinaryTree = Bfg.Containers.BinaryTrees.TBinaryTree;

  ICloneable = Bfg.Containers.Interfaces.ICloneable;

  { Iterator interfaces }
  IStrIterator = Bfg.Containers.Interfaces.IStrIterator;
  IIntIterator = Bfg.Containers.Interfaces.IIntIterator;
  IPtrIterator = Bfg.Containers.Interfaces.IPtrIterator;
  IIntfIterator = Bfg.Containers.Interfaces.IIntfIterator;
  IIterator = Bfg.Containers.Interfaces.IIterator;

  { Collection interfaces }
  IStrCollection = Bfg.Containers.Interfaces.IStrCollection;
  IIntCollection = Bfg.Containers.Interfaces.IIntCollection;
  IPtrCollection = Bfg.Containers.Interfaces.IPtrCollection;
  ICollection = Bfg.Containers.Interfaces.ICollection;

  { List itnerfaces }
  IStrList = Bfg.Containers.Interfaces.IStrList;
  IIntList = Bfg.Containers.Interfaces.IIntList;
  IPtrList = Bfg.Containers.Interfaces.IPtrList;
  IList = Bfg.Containers.Interfaces.IList;

  { Set interfaces }
  IStrSet = Bfg.Containers.Interfaces.IStrSet;
  IIntSet = Bfg.Containers.Interfaces.IIntSet;
  IPtrSet = Bfg.Containers.Interfaces.IPtrSet;
  IIntfSet = Bfg.Containers.Interfaces.IIntfSet;
  ISet = Bfg.Containers.Interfaces.ISet;

  { Map interfaces }
  IStrMap = Bfg.Containers.Interfaces.IStrMap;
  IStrStrMap = Bfg.Containers.Interfaces.IStrStrMap;
  IStrIntMap = Bfg.Containers.Interfaces.IStrIntMap;
  IStrPtrMap = Bfg.Containers.Interfaces.IStrPtrMap;
  IIntMap = Bfg.Containers.Interfaces.IIntMap;
  IIntIntMap = Bfg.Containers.Interfaces.IIntIntMap;
  IIntPtrMap = Bfg.Containers.Interfaces.IIntPtrMap;
  IPtrPtrMap = Bfg.Containers.Interfaces.IPtrPtrMap;
  IMap = Bfg.Containers.Interfaces.IMap;

  { Queue interfaces }
  IStrQueue = Bfg.Containers.Interfaces.IStrQueue;
  IIntfQueue = Bfg.Containers.Interfaces.IIntfQueue;
  IPtrQueue = Bfg.Containers.Interfaces.IPtrQueue;
  IQueue = Bfg.Containers.Interfaces.IQueue;

  { Stack interfaces }
  IStrStack = Bfg.Containers.Interfaces.IStrStack;
  IIntfStack = Bfg.Containers.Interfaces.IIntfStack;
  IPtrStack = Bfg.Containers.Interfaces.IPtrStack;
  IStack = Bfg.Containers.Interfaces.IStack;

  { Tree interfaces }
  IStrTree = Bfg.Containers.Interfaces.IStrTree;
  IIntfTree = Bfg.Containers.Interfaces.IIntfTree;
  IPtrTree = Bfg.Containers.Interfaces.IPtrTree;
  ITree = Bfg.Containers.Interfaces.ITree;

implementation

end.
