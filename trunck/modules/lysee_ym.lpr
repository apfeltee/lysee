{==============================================================================}
{        UNIT: lysee_ym                                                        }
{ DESCRIPTION: year-month interger functions (FPC)                             }
{     CREATED: 2007/07/12                                                      }
{    MODIFIED: 2010/08/31                                                      }
{==============================================================================}
{ Copyright (c) 2007-2010, Li Yun Jie                                          }
{ All rights reserved.                                                         }
{                                                                              }
{ Redistribution and use in source and binary forms, with or without           }
{ modification, are permitted provided that the following conditions are met:  }
{                                                                              }
{ Redistributions of source code must retain the above copyright notice, this  }
{ list of conditions and the following disclaimer.                             }
{                                                                              }
{ Redistributions in binary form must reproduce the above copyright notice,    }
{ this list of conditions and the following disclaimer in the documentation    }
{ and/or other materials provided with the distribution.                       }
{                                                                              }
{ Neither the name of Li Yun Jie nor the names of its contributors may         }
{ be used to endorse or promote products derived from this software without    }
{ specific prior written permission.                                           }
{                                                                              }
{ THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"  }
{ AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE    }
{ IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE   }
{ ARE DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE FOR  }
{ ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL       }
{ DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR   }
{ SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER   }
{ CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT           }
{ LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY    }
{ OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH  }
{ DAMAGE.                                                                      }
{==============================================================================}
{ The Initial Developer of the Original Code is Li Yun Jie (CHINA).            }
{ Portions created by Li Yun Jie are Copyright (C) 2007-2010.                  }
{ All Rights Reserved.                                                         }
{==============================================================================}
{ Contributor(s):                                                              }
{==============================================================================}
library lysee_ym;

{$mode objfpc}{$H+}

uses
  Classes,
  lseu in '../lseu.pas',
  lse_funcs in '../lse_funcs.pas',
  lysee_ym_funcs;

procedure InitExchange(const MR: PLseModuleRec; const QE: TLseQueryEntry);cdecl;
begin
  lse_prepare(QE);
  MR^.iw_production     := 'fpc ym module for lysee';
  MR^.iw_version        := LSE_VERSION;
  MR^.iw_copyright      := LSE_COPYRIGHT;
  MR^.iw_desc           := MR^.iw_production;
  MR^.iw_homepage       := LSE_HOMEPAGE;
  MR^.iw_email          := LSE_EMAIL;
  MR^.iw_libfuncs.count := ym_func_count;
  MR^.iw_libfuncs.entry :=@ym_func_array;
  MR^.iw_invoke         :=@lse_call_gate;
end;

exports
  InitExchange;

{$IFDEF WINDOWS}{$R lysee_ym.rc}{$ENDIF}

begin

end.
