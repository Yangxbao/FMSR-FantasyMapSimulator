
void HeightMapGenerator__smooth(longlong param_1,undefined8 param_2,undefined8 param_3)

{
  uint uVar1;
  longlong lVar2;
  char cVar3;
  int iVar4;
  int iVar5;
  int iVar6;
  undefined4 uVar7;
  longlong lVar8;
  longlong lVar9;
  longlong lVar10;
  int iVar11;
  int iVar12;
  double dVar13;
  int iVar14;
  int iVar15;
  undefined8 local_98;
  undefined8 uStack_90;
  ulonglong local_88;
  longlong local_80;
  longlong local_78;
  longlong local_70;
  undefined4 local_60;
  undefined4 uStack_5c;
  undefined4 uStack_58;
  undefined4 uStack_54;
  ulonglong local_50;
  
  if (DAT_18305fb9f == '\0') {
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebcce8);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182edbc38);
    DAT_18305fb9f = '\x01';
  }
  local_98 = 0;
  uStack_90 = 0;
  local_88 = 0;
  iVar4 = System_Int32__Parse(param_2,0);
  iVar5 = System_Int32__Parse(param_3,0);
  lVar8 = thunk_FUN_1802a5470(DAT_182edbc38);
  local_70 = lVar8;
  if (lVar8 != 0) {
    FUN_1813e2b90(lVar8,DAT_182ebcce8);
    iVar11 = 0;
    iVar12 = 0;
    local_80 = lVar8;
    while (lVar10 = local_70, lVar9 = *(longlong *)(param_1 + 0x18), lVar9 != 0) {
      if (*(int *)(lVar9 + 0x18) <= iVar11) goto LAB_1803901af;
      iVar14 = iVar11;
      iVar6 = FUN_1813fe630(lVar9,iVar11,DAT_182ebe118);
      iVar15 = iVar6;
      lVar9 = thunk_FUN_1802a5470(DAT_182edbc38);
      if (lVar9 == 0) break;
      FUN_1813e2b90(lVar9,DAT_182ebcce8);
      lVar2 = DAT_182ebcf70;
      *(int *)(lVar9 + 0x1c) = *(int *)(lVar9 + 0x1c) + 1;
      lVar10 = *(longlong *)(lVar9 + 0x10);
      if (lVar10 == 0) break;
      uVar1 = *(uint *)(lVar9 + 0x18);
      if (uVar1 < *(uint *)(lVar10 + 0x18)) {
        *(uint *)(lVar9 + 0x18) = uVar1 + 1;
        if (*(uint *)(lVar10 + 0x18) <= uVar1) {
                    /* WARNING: Subroutine does not return */
          FUN_180233670();
        }
        *(int *)(lVar10 + 0x20 + (longlong)(int)uVar1 * 4) = iVar6;
      }
      else {
        lVar10 = *(longlong *)(*(longlong *)(*(longlong *)(lVar2 + 0x20) + 0xc0) + 0x58);
        (**(code **)(lVar10 + 8))(lVar9,iVar6,lVar10,lVar10,iVar14,iVar15);
      }
      if ((*(longlong *)(param_1 + 0x10) == 0) ||
         (lVar10 = World__GetNeighborCells(*(longlong *)(param_1 + 0x10),iVar11,0), lVar10 == 0))
      break;
      local_78 = lVar9;
      FUN_1813f96b0(&local_60,lVar10,DAT_182ebd480);
      local_98 = CONCAT44(uStack_5c,local_60);
      uStack_90 = CONCAT44(uStack_54,uStack_58);
      local_88 = local_50;
      while (cVar3 = FUN_1811a17e0(&local_98,DAT_182ef2178), cVar3 != '\0') {
        if (*(longlong *)(param_1 + 0x18) == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        uVar7 = FUN_1813fe630(*(longlong *)(param_1 + 0x18),local_88 & 0xffffffff,DAT_182ebe118);
        FUN_1800048f0(lVar9,uVar7,DAT_182ebcf70);
      }
      AISystemState__Start(&local_98,DAT_182ef20a0);
      dVar13 = (double)System_Linq_Enumerable__Average(lVar9,0);
      if (iVar4 == 1) {
        dVar13 = dVar13 + (double)iVar5;
      }
      else {
        dVar13 = (double)MathUtility__Lim(SUB84((dVar13 + (double)((iVar4 + -1) * iVar6) +
                                                (double)iVar5) / (double)iVar4,0),0);
      }
      FUN_1800048f0(lVar8,(int)dVar13,DAT_182ebcf70);
      iVar11 = iVar11 + 1;
    }
  }
LAB_180390219:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
LAB_1803901af:
  while( true ) {
    if (*(int *)(lVar10 + 0x18) <= iVar12) {
      return;
    }
    lVar9 = *(longlong *)(param_1 + 0x18);
    uVar7 = FUN_1813fe630(lVar8,iVar12,DAT_182ebe118);
    if (lVar9 == 0) break;
    FUN_181409950(lVar9,iVar12,uVar7,DAT_182ebe2c8);
    iVar12 = iVar12 + 1;
  }
  goto LAB_180390219;
}

