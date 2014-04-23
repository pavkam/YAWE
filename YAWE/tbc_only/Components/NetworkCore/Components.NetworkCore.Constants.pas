{*------------------------------------------------------------------------------
  All World constants go here.

  This program is free software. You can redistribute it and/or modify
  it under the terms of the GNU Lesser General Public License (LGPL)
  as published by the Free Software Foundation; either version 2 of
  the License.

  @Link http://www.yawe.co.uk
  @Copyright YAWE Team
  @Author PavkaM
  @Changes Seth
------------------------------------------------------------------------------}

{$I compiler.inc}

unit Components.NetworkCore.Constants;

interface

{ Logon Server Info }
const
  LS_AUTH_LOGON_CHALLENGE        = $00;
  LS_AUTH_LOGON_PROOF            = $01;
  LS_AUTH_RECONNECT_CHALLENGE    = $02;
  LS_AUTH_RECONNECT_PROOF        = $03;
  LS_REALM_LIST                  = $10;
  LS_XFER_INITIATE               = $30;
  LS_XFER_DATA                   = $31;
  LS_XFER_ACCEPT                 = $32;
  LS_XFER_RESUME                 = $33;
  LS_XFER_CANCEL                 = $34;

  { Logon Server error codes }
  LS_E_SUCCESS                   = $00;  { Logon Success }
  LS_E_IPBAN                     = $01;  { IP is Banned }
  LS_E_ACCOUNT_CLOSED            = $03;  { Account closed }
  LS_E_NO_ACCOUNT                = $04;  { Invalid account name }
  LS_E_ACCOUNT_IN_USE            = $06;  { Account already logged in }
  LS_E_PREORDER_TIME_LIMIT       = $07;  { Paytime }
  LS_E_SERVER_FULL               = $08;  { Server is full }
  LS_E_WRONG_BUILD_NUMBER        = $09;  { Wrong version }
  LS_E_UPDATE_CLIENT             = $0A;  { Client update screen }
  LS_E_ACCOUNT_FROZEN            = $0C;  { Account suspended }


{ World Server Constants }
const
	AUTH_OK                       = $0C;  { Authentication successful }
	AUTH_FAILED		                = $0D;  { Authentication failed }
	AUTH_REJECT                   = $0E;  { Rejected - please contact customer support }
	AUTH_BAD_SERVER_PROOF         = $0F;  { Server is not valid }
	AUTH_UNAVAILABLE              = $10;  { System unavailable - please try again later }
	AUTH_SYSTEM_ERROR             = $11;  { System error }
	AUTH_BILLING_ERROR				    = $12;  { Billing system error }
	AUTH_BILLING_EXPIRED			    = $13;  { Account billing has expired }
	AUTH_VERSION_MISMATCH			    = $14;  { Wrong client version }
	AUTH_UNKNOWN_ACCOUNT			    = $15;  { Unknown account }
	AUTH_INCORRECT_PASSWORD			  = $16;  { Incorrect password }
	AUTH_SESSION_EXPIRED			    = $17;  { Session expired }
	AUTH_SERVER_SHUTTING_DOWN		  = $18;  { Server shutting down }
	AUTH_ALREADY_LOGGING_IN			  = $19;  { Already logging in }
	AUTH_LOGIN_SERVER_NOT_FOUND		= $1A;  { Invalid login server }
	AUTH_WAIT_QUEUE					      = $1B;  { Position in queue - (number) }

	// Others are  converted into nums ($27 -> "39")
		//	AUTH_CREATING_CHAR = 39,			// Creating character
		//	AUTH_CHAR_CREATE_SUCCESS = 40,		// Create success
		//	AUTH_ERR_CREATING_CHAR = 41,		// Error creating character
		//	AUTH_CHAR_CREATION_FAILED = 42,		// Character creation failed
		//	AUTH_CHAR_NAME_IN_USE = 43,			// Name already in use
		//	AUTH_RACE_CLASS_DISABLED = 44,		// Creation of that race and/or class is currently disabled
		//	AUTH_DELETING_CHAR = 45,			// Deleting character
		//	AUTH_CHAR_DELETED = 46,				// Character deleted
		//	AUTH_CHAR_DELETION_FAILED = 47,		// Character deletion failed
		//	AUTH_ENTERING_THE_WOW = 48,			// Entering the World of Warcraft
		//	AUTH_LOGIN_SUCCESS = 49,			// Login successful
		//	AUTH_WORLD_SERVER_DOWN = 50,			// World server is down
		//	AUTH_CHAR_WITH_THAT_NAME_ALREADY = 51,	// A character with that name already exists
		//	AUTH_NO_INSTANCE_SERVERS = 52,			// No instance servers are available
		//	AUTH_LOGIN_FAILED = 53,					// Login failed
		//	AUTH_LOGIN_RACE_CLASS_DISABLED = 54,	// Login for that race and/or class is currently disabled
		//	AUTH_ENTER_CHAR_NAME = 55,				// Enter a name for your character
		//	AUTH_NAME_MUST_BE_AT_LEAST_3 = 56,		// Name must be at least 3 characters
		//	AUTH_NAMES_NO_MORE_THAN_12 = 57,		// Names must be no more than 12 characters
		//	AUTH_NAME_MUST_START_WITH_LETTER = 58,	// Name must start with a letter
		//	AUTH_CAN_HAVE_1_GRAVE = 59,				// Names can only have one grave (`)
		//	AUTH_NAMES_CONTAIN_ONLY_LETTERS = 60,	// Names can only contain letters and one grave (`)
		//	AUTH_NAMES_ONLY_IN_ONE_LANGUAGE = 61,	// Names must contain only one language
		//	AUTH_NAME_CONTAINS_PROFANITY = 62,		// That name contains profanity
		//	AUTH_NAME_RESERVED = 63,			// That name is reserved
		//	AUTH_INVALID_CHAR_NAME = 64			// Invalid character name
implementation

end.
