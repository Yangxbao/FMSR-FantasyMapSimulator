
longlong HeightMapGenerator_<>c__DisplayClass16_0__<addTrough>g__GetRange_1
                   (longlong param_1,int param_2,int param_3,longlong *param_4)

{
  undefined8 uVar1;
  int iVar2;
  ulonglong uVar3;
  char cVar4;
  longlong lVar5;
  longlong lVar6;
  longlong lVar7;
  int iVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  undefined8 uVar12;
  undefined8 *puVar13;
  undefined8 local_d0;
  undefined8 uStack_c8;
  ulonglong local_c0;
  longlong local_b8;
  longlong *local_b0;
  undefined4 local_a0;
  undefined4 uStack_9c;
  undefined4 uStack_98;
  undefined4 uStack_94;
  ulonglong local_90;
  
  if (DAT_18305fbbf == '\0') {
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebce98);
    FUN_1802334a0(&DAT_182e98a68);
    FUN_1802334a0(&DAT_182e98b38);
    FUN_1802334a0(&DAT_182edbc38);
    FUN_1802334a0(&DAT_182edbcd0);
    DAT_18305fbbf = '\x01';
  }
  local_d0 = 0;
  uStack_c8 = 0;
  local_c0 = 0;
  lVar5 = thunk_FUN_1802a5470(DAT_182edbc38);
  if (lVar5 != 0) {
    lVar6 = lVar5;
    local_b0 = param_4;
    FUN_1813e2c20(lVar5,param_2,DAT_182ebce98);
    local_b8 = lVar5;
    while( true ) {
      if (param_2 == param_3) {
        return lVar5;
      }
      if (((*(longlong *)(param_1 + 0x10) == 0) ||
          (lVar5 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x10), lVar5 == 0)) ||
         (lVar5 = World__GetNeighborCells(lVar5,param_2,0), lVar5 == 0)) break;
      FUN_1813f96b0(&local_a0,lVar5,DAT_182ebd480);
      local_d0 = CONCAT44(uStack_9c,local_a0);
      uStack_c8 = CONCAT44(uStack_94,uStack_98);
      local_c0 = local_90;
      uVar12 = 0;
      fVar11 = 3.4028235e+38;
      iVar8 = -1;
      lVar5 = lVar6;
      puVar13 = &local_d0;
      while (cVar4 = FUN_1811a17e0(&local_d0,DAT_182ef2178), uVar3 = local_c0, cVar4 != '\0') {
        if (*param_4 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180233680();
        }
        iVar2 = (int)local_c0;
        cVar4 = FUN_1813fe680(*param_4,local_c0 & 0xffffffff,DAT_182e98a68);
        if (cVar4 == '\0') {
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar6 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x10);
          if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar6 = World__GetSite(lVar6,uVar3 & 0xffffffff,0);
          if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar7 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x10);
          if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          lVar7 = World__GetSite(lVar7,param_2,0);
          if (lVar7 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          uVar1 = *(undefined8 *)(lVar7 + 0x10);
          if (*(int *)(DAT_182edbcd0 + 0xe0) == 0) {
            il2cpp_runtime_class_init();
          }
          fVar9 = (float)csDelaunay_Vector2f__DistanceSquare(lVar6 + 0x10,uVar1,0);
          fVar10 = (float)UnityEngine_Random__get_value(0);
          if (0.8 < fVar10) {
            fVar9 = fVar9 * 0.5;
          }
          if (fVar9 < fVar11) {
            fVar11 = fVar9;
            iVar8 = iVar2;
          }
        }
      }
      AISystemState__Start(&local_d0,DAT_182ef20a0);
      if (iVar8 == -1) {
        return lVar5;
      }
      lVar6 = lVar5;
      FUN_1800048f0(lVar5,iVar8,DAT_182ebcf70);
      if (*param_4 == 0) break;
      FUN_1813fe780(*param_4,iVar8,1,DAT_182e98b38,lVar6,uVar12,puVar13);
      param_2 = iVar8;
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

