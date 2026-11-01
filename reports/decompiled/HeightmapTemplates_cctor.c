
void HeightmapTemplates___cctor(void)

{
  undefined8 uVar1;
  undefined8 uVar2;
  longlong lVar3;
  longlong lVar4;
  
  if (DAT_18305fbc5 == '\0') {
    FUN_1802334a0(&DAT_182e9ae98);
    FUN_1802334a0(&DAT_182edc260);
    FUN_1802334a0(&DAT_182e7c6f8);
    FUN_1802334a0(&DAT_182e7c620);
    FUN_1802334a0(&DAT_182ee96d0);
    FUN_1802334a0(&DAT_182ebefe0);
    FUN_1802334a0(&DAT_182e8d328);
    FUN_1802334a0(&DAT_182ebef08);
    FUN_1802334a0(&DAT_182eeb328);
    FUN_1802334a0(&DAT_182ebe5c0);
    FUN_1802334a0(&DAT_182ebee30);
    FUN_1802334a0(&DAT_182ebed58);
    FUN_1802334a0(&DAT_182ecc748);
    DAT_18305fbc5 = '\x01';
  }
  lVar3 = thunk_FUN_1802a5470(DAT_182ee96d0);
  if (lVar3 != 0) {
    FUN_1813e2b90(lVar3,DAT_182e7c620);
    lVar4 = thunk_FUN_1802a5470(DAT_182e9ae98);
    uVar2 = DAT_182ebef08;
    uVar1 = DAT_182e8d328;
    if (lVar4 != 0) {
      AISystemState__Start(lVar4,0);
      *(undefined8 *)(lVar4 + 0x10) = uVar1;
      FUN_180232f70(lVar4 + 0x10,uVar1);
      *(undefined8 *)(lVar4 + 0x18) = uVar2;
      FUN_180232f70(lVar4 + 0x18,uVar2);
      *(undefined4 *)(lVar4 + 0x20) = 3;
      FUN_180304090(lVar3,lVar4,DAT_182e7c6f8);
      lVar4 = thunk_FUN_1802a5470(DAT_182e9ae98);
      uVar2 = DAT_182ebefe0;
      uVar1 = DAT_182ebe5c0;
      if (lVar4 != 0) {
        AISystemState__Start(lVar4,0);
        *(undefined8 *)(lVar4 + 0x10) = uVar1;
        FUN_180232f70(lVar4 + 0x10,uVar1);
        *(undefined8 *)(lVar4 + 0x18) = uVar2;
        FUN_180232f70(lVar4 + 0x18,uVar2);
        *(undefined4 *)(lVar4 + 0x20) = 0x13;
        FUN_180304090(lVar3,lVar4,DAT_182e7c6f8);
        lVar4 = thunk_FUN_1802a5470(DAT_182e9ae98);
        uVar2 = DAT_182ecc748;
        uVar1 = DAT_182ebed58;
        if (lVar4 != 0) {
          AISystemState__Start(lVar4,0);
          *(undefined8 *)(lVar4 + 0x10) = uVar2;
          FUN_180232f70(lVar4 + 0x10,uVar2);
          *(undefined8 *)(lVar4 + 0x18) = uVar1;
          FUN_180232f70(lVar4 + 0x18,uVar1);
          *(undefined4 *)(lVar4 + 0x20) = 0x10;
          FUN_180304090(lVar3,lVar4,DAT_182e7c6f8);
          lVar4 = thunk_FUN_1802a5470(DAT_182e9ae98);
          uVar2 = DAT_182ecc748;
          uVar1 = DAT_182ebee30;
          if (lVar4 != 0) {
            AISystemState__Start(lVar4,0);
            *(undefined8 *)(lVar4 + 0x10) = uVar2;
            FUN_180232f70(lVar4 + 0x10,uVar2);
            *(undefined8 *)(lVar4 + 0x18) = uVar1;
            FUN_180232f70(lVar4 + 0x18,uVar1);
            *(undefined4 *)(lVar4 + 0x20) = 0x10;
            FUN_180304090(lVar3,lVar4,DAT_182e7c6f8);
            lVar4 = thunk_FUN_1802a5470(DAT_182e9ae98);
            uVar2 = DAT_182eeb328;
            uVar1 = DAT_182ecc748;
            if (lVar4 != 0) {
              AISystemState__Start(lVar4,0);
              *(undefined8 *)(lVar4 + 0x10) = uVar1;
              FUN_180232f70(lVar4 + 0x10,uVar1);
              *(undefined8 *)(lVar4 + 0x18) = uVar2;
              FUN_180232f70(lVar4 + 0x18,uVar2);
              *(undefined4 *)(lVar4 + 0x20) = 0x10;
              FUN_180304090(lVar3,lVar4,DAT_182e7c6f8);
              **(longlong **)(DAT_182edc260 + 0xb8) = lVar3;
              FUN_180232f70(*(undefined8 *)(DAT_182edc260 + 0xb8),lVar3);
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

