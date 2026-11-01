
void BurgsAndStateGenerator__RecalculateProvinceState(longlong param_1)

{
  longlong lVar1;
  longlong lVar2;
  char cVar3;
  undefined4 uVar4;
  undefined8 local_98;
  undefined8 uStack_90;
  longlong local_88;
  undefined8 local_80;
  undefined8 uStack_78;
  ulonglong local_70;
  undefined4 local_68;
  undefined4 uStack_64;
  undefined4 uStack_60;
  undefined4 uStack_5c;
  longlong local_58;
  undefined4 local_40;
  undefined4 uStack_3c;
  undefined4 uStack_38;
  undefined4 uStack_34;
  ulonglong local_30;
  
  if (DAT_18306022e == '\0') {
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182efd4f0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182efd5c8);
    FUN_1802334a0(&DAT_182efd698);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182ed7ac0);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    DAT_18306022e = '\x01';
  }
  local_80 = 0;
  uStack_78 = 0;
  local_70 = 0;
  lVar1 = *(longlong *)(param_1 + 0x10);
  if ((lVar1 == 0) || (*(longlong *)(lVar1 + 0x288) == 0)) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  lVar2 = *(longlong *)(lVar1 + 0x148);
  FUN_1813e0e20(&local_98,*(longlong *)(lVar1 + 0x288),DAT_182ed7ac0);
  local_68 = (undefined4)local_98;
  uStack_64 = local_98._4_4_;
  uStack_60 = (undefined4)uStack_90;
  uStack_5c = uStack_90._4_4_;
  local_58 = local_88;
  while( true ) {
    cVar3 = FUN_1811ab230(&local_68,DAT_182efd5c8);
    lVar1 = local_58;
    if (cVar3 == '\0') {
      AISystemState__Start(&local_68,DAT_182efd4f0);
      return;
    }
    if (lVar2 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    if (local_58 == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    if (*(longlong *)(lVar2 + 0xa8) == 0) break;
    uVar4 = FUN_1813fe630(*(longlong *)(lVar2 + 0xa8),*(undefined4 *)(local_58 + 0x48),DAT_182ebe118
                         );
    if (*(longlong *)(lVar1 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
      FUN_180233680();
    }
    FUN_1813f96b0(&local_40,*(longlong *)(lVar1 + 0xa8),DAT_182ebd480);
    local_80 = CONCAT44(uStack_3c,local_40);
    uStack_78 = CONCAT44(uStack_34,uStack_38);
    local_70 = local_30;
    local_98 = 0;
    uStack_90 = &local_80;
    while( true ) {
      cVar3 = FUN_1811a17e0(&local_80,DAT_182ef2178);
      if (cVar3 == '\0') break;
      if (*(longlong *)(lVar2 + 0xa8) == 0) {
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      FUN_181409950(*(longlong *)(lVar2 + 0xa8),local_70 & 0xffffffff,uVar4,DAT_182ebe2c8);
    }
    AISystemState__Start(&local_80,DAT_182ef20a0);
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

