
void SaveSystem__EncryptString(undefined8 param_1)

{
  undefined8 uVar1;
  longlong *plVar2;
  longlong *plVar3;
  undefined8 uVar4;
  longlong lVar5;
  longlong *local_res18;
  longlong *local_res20;
  longlong *local_98;
  longlong local_90;
  undefined8 local_88;
  undefined8 local_80;
  longlong **local_78;
  undefined8 local_70;
  longlong *local_68;
  undefined8 local_60;
  longlong **local_58;
  undefined8 local_50;
  longlong **local_48;
  
  if (DAT_1830602f8 == '\0') {
    FUN_1802334a0(&DAT_182e94ff0);
    FUN_1802334a0(&DAT_182e7fc98);
    FUN_1802334a0(&DAT_182eb2348);
    FUN_1802334a0(&DAT_182eb3500);
    FUN_1802334a0(&DAT_182ee2ed8);
    FUN_1802334a0(&DAT_182e80550);
    FUN_1802334a0(&DAT_182ebe080);
    FUN_1802334a0(&DAT_182ef4498);
    DAT_1830602f8 = '\x01';
  }
  local_88 = 0;
  local_res20 = (longlong *)0x0;
  local_90 = 0;
  local_98 = (longlong *)0x0;
  uVar1 = FUN_180232fe0(DAT_182e7fc98,0x10);
  if (*(int *)(DAT_182e94ff0 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  plVar2 = (longlong *)System_Security_Cryptography_Aes__Create(0);
  local_50 = 0;
  local_48 = &local_res18;
  local_res18 = plVar2;
  plVar3 = (longlong *)System_Text_Encoding__get_UTF8(0);
  if (plVar3 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  uVar4 = (**(code **)(*plVar3 + 0x268))(plVar3,DAT_182ef4498,*(undefined8 *)(*plVar3 + 0x270));
  if (plVar2 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  (**(code **)(*plVar2 + 0x1f8))(plVar2,uVar4,*(undefined8 *)(*plVar2 + 0x200));
  if (local_res18 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  (**(code **)(*local_res18 + 0x1d8))(local_res18,uVar1,*(undefined8 *)(*local_res18 + 0x1e0));
  plVar2 = local_res18;
  if (local_res18 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  uVar1 = (**(code **)(*local_res18 + 0x1e8))(local_res18,*(undefined8 *)(*local_res18 + 0x1f0));
  if (local_res18 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  uVar4 = (**(code **)(*local_res18 + 0x1c8))(local_res18,*(undefined8 *)(*local_res18 + 0x1d0));
  lVar5 = *plVar2;
  uVar1 = (**(code **)(lVar5 + 0x288))(plVar2,uVar1,uVar4,*(undefined8 *)(lVar5 + 0x290));
  plVar2 = (longlong *)thunk_FUN_1802a5470(DAT_182e80550);
  if (plVar2 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  System_IO_MemoryStream___ctor(plVar2,0);
  local_60 = 0;
  local_58 = &local_res20;
  local_res20 = plVar2;
  lVar5 = thunk_FUN_1802a5470(DAT_182eb3500);
  if (lVar5 != 0) {
    System_Security_Cryptography_CryptoStream___ctor(lVar5,plVar2,uVar1,1,0);
    local_70 = 0;
    local_68 = &local_90;
    local_90 = lVar5;
    plVar2 = (longlong *)thunk_FUN_1802a5470(DAT_182ebe080);
    if (plVar2 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    System_IO_StreamWriter___ctor(plVar2,lVar5,0);
    local_80 = 0;
    local_78 = &local_98;
    local_98 = plVar2;
    if (plVar2 != (longlong *)0x0) {
      (**(code **)(*plVar2 + 0x248))(plVar2,param_1,*(undefined8 *)(*plVar2 + 0x250));
      if (local_98 != (longlong *)0x0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      if (local_res20 != (longlong *)0x0) {
        uVar1 = (**(code **)(*local_res20 + 1000))
                          (local_res20,*(undefined8 *)(*local_res20 + 0x3f0));
        local_88 = uVar1;
        if (local_90 != 0) {
          FUN_180002f00(0,DAT_182ee2ed8);
        }
        if (local_res20 != (longlong *)0x0) {
          FUN_180002f00(0,DAT_182ee2ed8);
        }
        if (local_res18 != (longlong *)0x0) {
          FUN_180002f00(0,DAT_182ee2ed8);
        }
        if (*(int *)(DAT_182eb2348 + 0xe0) == 0) {
          il2cpp_runtime_class_init();
        }
        System_Convert__ToBase64String(uVar1,0);
        return;
      }
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

