
undefined8 CustomLoader__DecryptString(undefined8 param_1)

{
  undefined8 uVar1;
  undefined8 uVar2;
  longlong *plVar3;
  longlong *plVar4;
  undefined8 uVar5;
  longlong lVar6;
  longlong lVar7;
  longlong *local_res8 [2];
  longlong *local_res18;
  longlong local_res20;
  longlong local_98;
  undefined8 local_90;
  undefined8 local_88;
  longlong **local_80;
  undefined8 local_78;
  longlong *local_70;
  undefined8 local_68;
  longlong *local_60;
  undefined8 local_58;
  longlong **local_50;
  
  if (DAT_18305fb91 == '\0') {
    FUN_1802334a0(&DAT_182e94ff0);
    FUN_1802334a0(&DAT_182e7fc98);
    FUN_1802334a0(&DAT_182eb2348);
    FUN_1802334a0(&DAT_182eb3500);
    FUN_1802334a0(&DAT_182ee2ed8);
    FUN_1802334a0(&DAT_182e80550);
    FUN_1802334a0(&DAT_182ebdfa8);
    FUN_1802334a0(&DAT_182ef4570);
    DAT_18305fb91 = '\x01';
  }
  local_98 = 0;
  local_res20 = 0;
  local_res18 = (longlong *)0x0;
  local_90 = 0;
  uVar1 = FUN_180232fe0(DAT_182e7fc98,0x10);
  if (*(int *)(DAT_182eb2348 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  uVar2 = System_Convert__FromBase64String(param_1,0);
  if (*(int *)(DAT_182e94ff0 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  plVar3 = (longlong *)System_Security_Cryptography_Aes__Create(0);
  local_58 = 0;
  local_50 = local_res8;
  local_res8[0] = plVar3;
  plVar4 = (longlong *)System_Text_Encoding__get_UTF8(0);
  if (plVar4 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  uVar5 = (**(code **)(*plVar4 + 0x268))(plVar4,DAT_182ef4570,*(undefined8 *)(*plVar4 + 0x270));
  if (plVar3 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  (**(code **)(*plVar3 + 0x1f8))(plVar3,uVar5,*(undefined8 *)(*plVar3 + 0x200));
  if (local_res8[0] == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  (**(code **)(*local_res8[0] + 0x1d8))(local_res8[0],uVar1,*(undefined8 *)(*local_res8[0] + 0x1e0))
  ;
  plVar3 = local_res8[0];
  if (local_res8[0] == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  uVar1 = (**(code **)(*local_res8[0] + 0x1e8))
                    (local_res8[0],*(undefined8 *)(*local_res8[0] + 0x1f0));
  if (local_res8[0] == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  uVar5 = (**(code **)(*local_res8[0] + 0x1c8))
                    (local_res8[0],*(undefined8 *)(*local_res8[0] + 0x1d0));
  lVar6 = *plVar3;
  uVar1 = (**(code **)(lVar6 + 0x2a8))(plVar3,uVar1,uVar5,*(undefined8 *)(lVar6 + 0x2b0));
  lVar6 = thunk_FUN_1802a5470(DAT_182e80550);
  if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  System_IO_MemoryStream___ctor(lVar6,uVar2,0);
  local_68 = 0;
  local_60 = &local_98;
  local_98 = lVar6;
  lVar7 = thunk_FUN_1802a5470(DAT_182eb3500);
  if (lVar7 != 0) {
    System_Security_Cryptography_CryptoStream___ctor(lVar7,lVar6,uVar1,0,0);
    local_78 = 0;
    local_70 = &local_res20;
    local_res20 = lVar7;
    plVar3 = (longlong *)thunk_FUN_1802a5470(DAT_182ebdfa8);
    if (plVar3 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    System_IO_StreamReader___ctor(plVar3,lVar7,0);
    local_88 = 0;
    local_80 = &local_res18;
    local_res18 = plVar3;
    if (plVar3 != (longlong *)0x0) {
      uVar1 = (**(code **)(*plVar3 + 0x208))(plVar3,*(undefined8 *)(*plVar3 + 0x210));
      local_90 = uVar1;
      if (local_res18 != (longlong *)0x0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      if (local_res20 != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      if (local_98 != 0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      if (local_res8[0] != (longlong *)0x0) {
        FUN_180002f00(0,DAT_182ee2ed8);
      }
      return uVar1;
    }
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

