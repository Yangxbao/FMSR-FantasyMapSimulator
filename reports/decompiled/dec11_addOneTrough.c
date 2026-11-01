
void HeightMapGenerator_<>c__DisplayClass16_0__<addTrough>g__addOneTrough_0(longlong param_1)

{
  longlong lVar1;
  ulonglong uVar2;
  char cVar3;
  int iVar4;
  undefined4 uVar5;
  int iVar6;
  undefined4 uVar7;
  undefined8 uVar8;
  longlong lVar9;
  longlong lVar10;
  uint uVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  double dVar16;
  int local_res18;
  longlong local_198;
  longlong local_190;
  undefined8 local_188;
  undefined8 uStack_180;
  ulonglong local_178;
  longlong local_170;
  longlong local_168;
  undefined8 local_160;
  undefined8 *local_158;
  undefined8 local_150;
  undefined8 uStack_148;
  ulonglong local_140;
  undefined8 local_138;
  undefined8 *local_130;
  undefined8 local_128;
  undefined8 *local_120;
  undefined8 local_118;
  undefined8 uStack_110;
  ulonglong local_108;
  longlong local_100;
  longlong local_f8;
  
  if (DAT_18305fbbd == '\0') {
    FUN_1802334a0(&DAT_182ee6048);
    FUN_1802334a0(&DAT_182eef608);
    FUN_1802334a0(&DAT_182ef3668);
    FUN_1802334a0(&DAT_182e7f448);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182e95558);
    FUN_1802334a0(&DAT_182edc188);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182ebd1f8);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebcdc0);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182e98a68);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182e98b38);
    FUN_1802334a0(&DAT_182edbc38);
    FUN_1802334a0(&DAT_182ecb3e0);
    DAT_18305fbbd = '\x01';
  }
  local_188 = 0;
  uStack_180 = 0;
  local_178 = 0;
  local_118 = 0;
  uStack_110 = 0;
  local_108 = 0;
  if ((*(longlong *)(param_1 + 0x10) != 0) &&
     (lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x18), lVar9 != 0)) {
    local_168 = param_1;
    uVar8 = FUN_180c097e0(0,*(undefined4 *)(lVar9 + 0x18),DAT_182ef3668);
    local_198 = FUN_180c22330(uVar8,DAT_182e7f448);
    FUN_180232f70(&local_198,local_198);
    iVar4 = RandomUtils__GetNumberInRange(*(undefined8 *)(param_1 + 0x18),0);
    dVar16 = (double)MathUtility__Lim((double)iVar4,0);
    iVar4 = 0;
    do {
      if (*(longlong *)(param_1 + 0x10) == 0) goto LAB_1803a64b1;
      uVar8 = *(undefined8 *)(param_1 + 0x20);
      if (*(int *)(DAT_182edc188 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      fVar12 = (float)HeightMapGenerator__GetPointInRange(uVar8);
      if (*(longlong *)(param_1 + 0x10) == 0) goto LAB_1803a64b1;
      fVar13 = (float)HeightMapGenerator__GetPointInRange(*(undefined8 *)(param_1 + 0x28));
      if ((*(longlong *)(param_1 + 0x10) == 0) ||
         (*(longlong *)(*(longlong *)(param_1 + 0x10) + 0x10) == 0)) goto LAB_1803a64b1;
      uVar5 = World__GetCellIndex();
      if ((*(longlong *)(param_1 + 0x10) == 0) ||
         (lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x18), lVar9 == 0))
      goto LAB_1803a64b1;
      iVar4 = iVar4 + 1;
      iVar6 = FUN_1813fe630(lVar9,uVar5);
    } while ((iVar6 < 0x14) && (iVar4 < 0x32));
    do {
      if ((*(longlong *)(param_1 + 0x10) == 0) ||
         (lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x10), lVar9 == 0))
      goto LAB_1803a64b1;
      fVar14 = (float)UnityEngine_Random__Range(lVar9,(float)*(int *)(lVar9 + 0x138) * 0.8,0);
      if ((*(longlong *)(param_1 + 0x10) == 0) ||
         (lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x10), lVar9 == 0))
      goto LAB_1803a64b1;
      iVar6 = *(int *)(lVar9 + 0x138);
      fVar15 = (float)UnityEngine_Random__Range(lVar9,(float)*(int *)(lVar9 + 0x13c) * 0.7,0);
      lVar9 = *(longlong *)(param_1 + 0x10);
      if ((lVar9 == 0) || (*(longlong *)(lVar9 + 0x10) == 0)) goto LAB_1803a64b1;
      fVar14 = ABS((fVar14 + (float)iVar6 * 0.1) - fVar12) +
               ABS(((float)*(int *)(*(longlong *)(lVar9 + 0x10) + 0x13c) * 0.15 + fVar15) - fVar13);
      uVar11 = *(int *)(lVar9 + 0x28) >> 0x1f & 7;
    } while (((fVar14 < (float)((int)(*(int *)(lVar9 + 0x28) + uVar11) >> 3)) ||
             (iVar6 = *(int *)(*(longlong *)(param_1 + 0x10) + 0x28), uVar11 = iVar6 >> 0x1f,
             (float)(iVar6 / 2) < fVar14)) && (iVar4 = iVar4 + 1, iVar4 < 0x32));
    uVar5 = World__GetCellIndex(*(undefined8 *)(*(longlong *)(param_1 + 0x10) + 0x10),uVar11,fVar13,
                                0);
    if ((*(longlong *)(param_1 + 0x10) != 0) &&
       (*(longlong *)(*(longlong *)(param_1 + 0x10) + 0x10) != 0)) {
      uVar7 = World__GetCellIndex();
      lVar9 = HeightMapGenerator_<>c__DisplayClass16_0__<addTrough>g__GetRange_1
                        (param_1,uVar5,uVar7,&local_198,0);
      local_f8 = lVar9;
      lVar10 = thunk_FUN_1802a5470(DAT_182edbc38);
      if (lVar10 != 0) {
        local_170 = lVar9;
        FUN_1813e2970(lVar10,lVar9,DAT_182ebcdc0);
        fVar12 = (float)dVar16;
        local_res18 = 0;
        local_190 = lVar10;
        while (0 < *(int *)(lVar10 + 0x18)) {
          lVar9 = thunk_FUN_1802a5470(DAT_182edbc38);
          local_100 = lVar9;
          if (lVar9 == 0) goto LAB_1803a64b1;
          FUN_1813e2970(lVar9,lVar10,DAT_182ebcdc0);
          *(int *)(lVar10 + 0x1c) = *(int *)(lVar10 + 0x1c) + 1;
          *(undefined4 *)(lVar10 + 0x18) = 0;
          FUN_1813f96b0(&local_150,lVar9,DAT_182ebd480);
          local_188 = local_150;
          uStack_180 = uStack_148;
          local_178 = local_140;
          local_138 = 0;
          local_130 = &local_188;
          while (cVar3 = FUN_1811a17e0(&local_188,DAT_182ef2178), uVar2 = local_178, cVar3 != '\0')
          {
            if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar1 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x18);
            if (lVar1 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            iVar4 = FUN_1813fe630(lVar1,local_178 & 0xffffffff,DAT_182ebe118);
            fVar13 = (float)UnityEngine_Random__Range();
            dVar16 = (double)MathUtility__Lim((double)((float)iVar4 - (fVar13 + 0.85) * fVar12),0);
            FUN_181409950(lVar1,uVar2 & 0xffffffff,(int)dVar16);
          }
          AISystemState__Start(&local_188,DAT_182ef20a0);
          if (*(longlong *)(param_1 + 0x10) == 0) goto LAB_1803a64b1;
          local_res18 = local_res18 + 1;
          fVar12 = (float)FUN_1802d1a20();
          fVar12 = fVar12 - 1.0;
          if (fVar12 < 2.0) break;
          FUN_1813f96b0(&local_150,lVar9,DAT_182ebd480);
          local_188 = local_150;
          uStack_180 = uStack_148;
          local_178 = local_140;
          local_160 = 0;
          local_158 = &local_188;
          while (cVar3 = FUN_1811a17e0(&local_188,DAT_182ef2178), cVar3 != '\0') {
            if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar9 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x10);
            if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            lVar9 = World__GetNeighborCells(lVar9,local_178 & 0xffffffff,0);
            if (lVar9 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            FUN_1813f96b0(&local_150,lVar9);
            local_118 = local_150;
            uStack_110 = uStack_148;
            local_108 = local_140;
            local_128 = 0;
            local_120 = &local_118;
            while (cVar3 = FUN_1811a17e0(&local_118,DAT_182ef2178), uVar2 = local_108, cVar3 != '\0'
                  ) {
              if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
                FUN_180233680();
              }
              cVar3 = FUN_1813fe680(local_198,local_108 & 0xffffffff);
              if (cVar3 == '\0') {
                FUN_1800048f0(lVar10,uVar2 & 0xffffffff,DAT_182ebcf70);
                if (local_198 == 0) {
                    /* WARNING: Subroutine does not return */
                  FUN_180233680();
                }
                FUN_1813fe780(local_198,uVar2 & 0xffffffff);
              }
            }
            AISystemState__Start(&local_118,DAT_182ef20a0);
          }
          AISystemState__Start(local_158,DAT_182ef20a0);
        }
        iVar4 = 0;
        if (local_170 != 0) {
          do {
            if (*(int *)(local_f8 + 0x18) <= iVar4) {
              return;
            }
            if (iVar4 == (iVar4 / 6 + (iVar4 >> 0x1f) +
                         (int)(((longlong)iVar4 / 6 + ((longlong)iVar4 >> 0x3f) & 0xffffffffU) >>
                              0x1f)) * 6) {
              uVar5 = FUN_1813fe630(local_170,iVar4,DAT_182ebe118);
              lVar9 = local_168;
              iVar6 = 0;
              if (0 < local_res18) {
                do {
                  if ((*(longlong *)(lVar9 + 0x10) == 0) ||
                     (lVar10 = *(longlong *)(*(longlong *)(lVar9 + 0x10) + 0x10), lVar10 == 0))
                  goto LAB_1803a64b1;
                  uVar8 = World__GetNeighborCells(lVar10,uVar5,0);
                  lVar10 = *(longlong *)(param_1 + 0x30);
                  if (lVar10 == 0) {
                    lVar10 = thunk_FUN_1802a5470(DAT_182e95558);
                    if (lVar10 == 0) goto LAB_1803a64b1;
                    FUN_18129a570(lVar10,param_1,DAT_182ecb3e0,0);
                    *(longlong *)(param_1 + 0x30) = lVar10;
                    FUN_180232f70(param_1 + 0x30,lVar10);
                  }
                  uVar8 = FUN_180c09290(uVar8,lVar10,DAT_182eef608);
                  uVar7 = FUN_180c06730(uVar8,DAT_182ee6048);
                  if ((*(longlong *)(param_1 + 0x10) == 0) ||
                     (lVar10 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x18), lVar10 == 0))
                  goto LAB_1803a64b1;
                  FUN_1813fe630(lVar10,uVar5,DAT_182ebe118);
                  if ((*(longlong *)(param_1 + 0x10) == 0) ||
                     (lVar1 = *(longlong *)(*(longlong *)(param_1 + 0x10) + 0x18), lVar1 == 0))
                  goto LAB_1803a64b1;
                  FUN_1813fe630(lVar1,uVar7,DAT_182ebe118);
                  FUN_181409950(lVar10,uVar7);
                  iVar6 = iVar6 + 1;
                  uVar5 = uVar7;
                } while (iVar6 < local_res18);
              }
            }
            iVar4 = iVar4 + 1;
          } while( true );
        }
      }
    }
  }
LAB_1803a64b1:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

