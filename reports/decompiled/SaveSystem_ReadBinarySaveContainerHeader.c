
longlong SaveSystem__ReadBinarySaveContainerHeader(undefined8 param_1)

{
  char cVar1;
  int iVar2;
  undefined8 uVar3;
  longlong *plVar4;
  longlong lVar5;
  longlong lVar6;
  longlong lVar7;
  undefined8 uVar8;
  longlong local_res8 [2];
  longlong *local_res18;
  longlong local_res20;
  
  if (DAT_183060310 == '\0') {
    FUN_1802334a0(&DAT_182ea0b20);
    FUN_1802334a0(&DAT_182ec8f60);
    FUN_1802334a0(&DAT_182f00d90);
    FUN_1802334a0(&DAT_182ee2ed8);
    FUN_1802334a0(&DAT_182ead748);
    DAT_183060310 = '\x01';
  }
  uVar3 = System_Text_Encoding__get_UTF8(0);
  plVar4 = (longlong *)thunk_FUN_1802a5470(DAT_182ea0b20);
  if (plVar4 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  local_res20 = 0;
  System_IO_BinaryReader___ctor(plVar4,param_1,uVar3,1,0);
  local_res18 = plVar4;
  if (*(int *)(DAT_182ead748 + 0xe0) == 0) {
    il2cpp_runtime_class_init(DAT_182ead748);
  }
  lVar5 = *(longlong *)(*(longlong *)(DAT_182ead748 + 0xb8) + 8);
  if (lVar5 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  if (plVar4 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  lVar5 = (**(code **)(*plVar4 + 0x2c8))
                    (plVar4,*(undefined4 *)(lVar5 + 0x18),*(undefined8 *)(*plVar4 + 0x2d0));
  if (lVar5 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  lVar6 = *(longlong *)(*(longlong *)(DAT_182ead748 + 0xb8) + 8);
  if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  if (*(int *)(lVar5 + 0x18) == *(int *)(lVar6 + 0x18)) {
    if (*(int *)(DAT_182ead748 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    cVar1 = FUN_180bc91e0(lVar5,*(undefined8 *)(*(longlong *)(DAT_182ead748 + 0xb8) + 8),
                          DAT_182f00d90);
    if (cVar1 != '\0') {
      if (local_res18 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      iVar2 = (**(code **)(*local_res18 + 0x228))(local_res18,*(undefined8 *)(*local_res18 + 0x230))
      ;
      if (iVar2 != 1) {
        local_res8[0] = CONCAT44(local_res8[0]._4_4_,iVar2);
        uVar3 = thunk_FUN_180225b60(&DAT_182ef5870);
        uVar3 = il2cpp_value_box(uVar3,local_res8);
        uVar8 = thunk_FUN_180225b60(&DAT_182e7bd00);
        uVar3 = System_String__Format(uVar8,uVar3,0);
        uVar8 = thunk_FUN_180225b60(&DAT_182e8cf90);
        uVar8 = thunk_FUN_1802a5470(uVar8);
        FUN_180002ff0(uVar8);
        System_NotSupportedException___ctor(uVar8,uVar3,0);
        uVar3 = thunk_FUN_180225b60(&DAT_182ecdaf0);
                    /* WARNING: Subroutine does not return */
        FUN_180233640(uVar8,uVar3);
      }
      if (local_res18 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      lVar5 = (**(code **)(*local_res18 + 0x248))(local_res18,*(undefined8 *)(*local_res18 + 0x250))
      ;
      if (lVar5 < 1) {
        local_res8[0] = lVar5;
        uVar3 = thunk_FUN_180225b60(&DAT_182ef5c90);
        uVar3 = il2cpp_value_box(uVar3,local_res8);
        uVar8 = thunk_FUN_180225b60(&DAT_182edcea8);
        uVar3 = System_String__Format(uVar8,uVar3,0);
        uVar8 = thunk_FUN_180225b60(&DAT_182ef77e0);
        uVar8 = thunk_FUN_1802a5470(uVar8);
        FUN_180002ff0(uVar8);
        System_IO_InvalidDataException___ctor(uVar8,uVar3,0);
        uVar3 = thunk_FUN_180225b60(&DAT_182ecdaf0);
                    /* WARNING: Subroutine does not return */
        FUN_180233640(uVar8,uVar3);
      }
      if (local_res18 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      lVar6 = (**(code **)(*local_res18 + 0x2c8))
                        (local_res18,0x10,*(undefined8 *)(*local_res18 + 0x2d0));
      if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (*(int *)(lVar6 + 0x18) != 0x10) {
        uVar3 = thunk_FUN_180225b60(&DAT_182ec7b68);
        uVar3 = thunk_FUN_1802a5470(uVar3);
        FUN_180002ff0(uVar3);
        uVar8 = thunk_FUN_180225b60(&DAT_182e8fb58);
        System_IO_EndOfStreamException___ctor(uVar3,uVar8,0);
        uVar8 = thunk_FUN_180225b60(&DAT_182ecdaf0);
                    /* WARNING: Subroutine does not return */
        FUN_180233640(uVar3,uVar8);
      }
      lVar7 = thunk_FUN_1802a5470(DAT_182ec8f60);
      if (lVar7 != 0) {
        MostEnemyArmyProvinceStrategy___ctor(lVar7,0);
        *(undefined4 *)(lVar7 + 0x10) = 1;
        *(longlong *)(lVar7 + 0x18) = lVar5;
        *(longlong *)(lVar7 + 0x20) = lVar6;
        FUN_180232f70(lVar7 + 0x20,lVar6);
        if (local_res18 != (longlong *)0x0) {
          local_res20 = lVar7;
          FUN_180002f00(0,DAT_182ee2ed8);
        }
        return lVar7;
      }
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
  }
  uVar3 = thunk_FUN_180225b60(&DAT_182ef77e0);
  uVar3 = thunk_FUN_1802a5470(uVar3);
  FUN_180002ff0(uVar3);
  uVar8 = thunk_FUN_180225b60(&DAT_182edccf8);
  System_IO_InvalidDataException___ctor(uVar3,uVar8,0);
  uVar8 = thunk_FUN_180225b60(&DAT_182ecdaf0);
                    /* WARNING: Subroutine does not return */
  FUN_180233640(uVar3,uVar8);
}

