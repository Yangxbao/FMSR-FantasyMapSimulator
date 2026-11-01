
void HeightMapExternal__Init(longlong param_1)

{
  longlong lVar1;
  longlong lVar2;
  undefined8 uVar3;
  
  if (DAT_18305fb97 == '\0') {
    FUN_1802334a0(&DAT_182eae400);
    FUN_1802334a0(&DAT_182ee1bc0);
    FUN_1802334a0(&DAT_182efa718);
    FUN_1802334a0(&DAT_182e825e8);
    FUN_1802334a0(&DAT_182eb41a0);
    FUN_1802334a0(&DAT_182ee0fc8);
    DAT_18305fb97 = '\x01';
  }
  HeightMapExternal__Dispose(param_1,0);
  lVar1 = thunk_FUN_1802a5470(DAT_182eae400);
  if (lVar1 != 0) {
    if (DAT_18305fb93 == '\0') {
      FUN_1802334a0(&DAT_182eb4e50);
      FUN_1802334a0(&DAT_182ebf038);
      DAT_18305fb93 = '\x01';
    }
    AISystemState__Start(lVar1,0);
    lVar2 = thunk_FUN_1802a5470(DAT_182ebf038);
    if (lVar2 != 0) {
      Puerts_DefaultLoader___ctor(lVar2,0);
      *(longlong *)(lVar1 + 0x10) = lVar2;
      FUN_180232f70(lVar1 + 0x10,lVar2);
      lVar2 = thunk_FUN_1802a5470(DAT_182eb4e50);
      if (lVar2 != 0) {
        AISystemState__Start(lVar2,0);
        *(longlong *)(lVar1 + 0x18) = lVar2;
        FUN_180232f70(lVar1 + 0x18,lVar2);
        lVar2 = thunk_FUN_1802a5470(DAT_182efa718);
        if (lVar2 != 0) {
          Puerts_JsEnv___ctor(lVar2,lVar1,0xffffffff,0);
          *(longlong *)(param_1 + 0x18) = lVar2;
          FUN_180232f70(param_1 + 0x18,lVar2);
          if (*(longlong *)(param_1 + 0x18) != 0) {
            Puerts_JsEnv__ExecuteModule(*(longlong *)(param_1 + 0x18),DAT_182ee0fc8,0);
            if (*(longlong *)(param_1 + 0x18) != 0) {
              uVar3 = FUN_180c3a9d0(*(longlong *)(param_1 + 0x18),DAT_182eb41a0,DAT_182e825e8,
                                    DAT_182ee1bc0);
              *(undefined8 *)(param_1 + 0x20) = uVar3;
              FUN_180232f70(param_1 + 0x20,uVar3);
              return;
            }
          }
        }
      }
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

