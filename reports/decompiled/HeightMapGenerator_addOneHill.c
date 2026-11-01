
void HeightMapGenerator__<addHill>g__addOneHill_13_0(longlong param_1,longlong param_2)

{
  ulonglong uVar1;
  char cVar2;
  int iVar3;
  undefined4 uVar4;
  int iVar5;
  undefined8 uVar6;
  longlong lVar7;
  longlong lVar8;
  longlong lVar9;
  int iVar10;
  float fVar11;
  float fVar12;
  double dVar13;
  undefined8 local_a8;
  undefined8 uStack_a0;
  ulonglong local_98;
  undefined8 local_90;
  undefined8 uStack_88;
  ulonglong local_80;
  
  if (DAT_18305fba9 == '\0') {
    FUN_1802334a0(&DAT_182ef3c30);
    FUN_1802334a0(&DAT_182e82388);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182edc188);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ee41f0);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182ee4398);
    FUN_1802334a0(&DAT_182ecac80);
    FUN_1802334a0(&DAT_182ecad58);
    FUN_1802334a0(&DAT_182eca928);
    FUN_1802334a0(&DAT_182ecafe0);
    FUN_1802334a0(&DAT_182efa948);
    DAT_18305fba9 = '\x01';
  }
  local_a8 = 0;
  uStack_a0 = 0;
  local_98 = 0;
  if (*(longlong *)(param_1 + 0x18) != 0) {
    uVar6 = FUN_180c09a30();
    lVar7 = FUN_180c22f90(uVar6,DAT_182e82388);
    iVar10 = 0;
    iVar3 = RandomUtils__GetNumberInRange(*(undefined8 *)(param_2 + 8),0);
    dVar13 = (double)MathUtility__Lim((double)iVar3,0);
    iVar3 = iVar10;
    do {
      if (*(longlong *)(param_1 + 0x10) == 0) goto LAB_18038dee0;
      uVar6 = *(undefined8 *)(param_2 + 0x10);
      if (*(int *)(DAT_182edc188 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      HeightMapGenerator__GetPointInRange(uVar6);
      if ((*(longlong *)(param_1 + 0x10) == 0) ||
         (HeightMapGenerator__GetPointInRange(*(undefined8 *)(param_2 + 0x18)),
         *(longlong *)(param_1 + 0x10) == 0)) goto LAB_18038dee0;
      uVar4 = World__GetCellIndex();
      if (*(longlong *)(param_1 + 0x18) == 0) goto LAB_18038dee0;
      iVar5 = FUN_1813fe630(*(longlong *)(param_1 + 0x18),uVar4);
    } while ((90.0 < (float)iVar5 + (float)dVar13) && (iVar3 = iVar3 + 1, iVar3 < 0x32));
    if (lVar7 != 0) {
      FUN_181428fa0(lVar7,uVar4,(float)dVar13,DAT_182ee4398);
      lVar8 = thunk_FUN_1802a5470(DAT_182efa948);
      if (lVar8 != 0) {
        FUN_180defcd0(lVar8,DAT_182eca928);
        FUN_1814ee5f0(lVar8,uVar4,DAT_182ecad58);
        while (0 < *(int *)(lVar8 + 0x20)) {
          uVar4 = FUN_1814ede40(lVar8,DAT_182ecac80);
          if ((*(longlong *)(param_1 + 0x10) == 0) ||
             (lVar9 = World__GetNeighborCells(*(longlong *)(param_1 + 0x10),uVar4,0), lVar9 == 0))
          goto LAB_18038dee0;
          FUN_1813f96b0(&local_90,lVar9);
          local_a8 = local_90;
          uStack_a0 = uStack_88;
          local_98 = local_80;
          while (cVar2 = FUN_1811a17e0(&local_a8,DAT_182ef2178), uVar1 = local_98, cVar2 != '\0') {
            fVar11 = (float)FUN_181428f50(lVar7,local_98 & 0xffffffff);
            if (fVar11 == 0.0) {
              FUN_181428f50(lVar7,uVar4,DAT_182ee41f0);
              fVar11 = (float)FUN_1802d1a20();
              fVar12 = (float)UnityEngine_Random__get_value(0);
              FUN_181428fa0(lVar7,uVar1 & 0xffffffff,(fVar12 * 0.2 + 0.9) * fVar11,DAT_182ee4398);
              fVar11 = (float)FUN_181428f50(lVar7,uVar1 & 0xffffffff);
              if (1.0 < fVar11) {
                FUN_1814ee5f0(lVar8,uVar1 & 0xffffffff);
              }
            }
          }
          AISystemState__Start(&local_a8,DAT_182ef20a0);
        }
        lVar8 = *(longlong *)(param_1 + 0x18);
        while (lVar8 != 0) {
          if (*(int *)(lVar8 + 0x18) <= iVar10) {
            return;
          }
          fVar11 = (float)FUN_181428f50(lVar7,iVar10,DAT_182ee41f0);
          if (4.0 < fVar11) {
            lVar8 = *(longlong *)(param_1 + 0x18);
            if (lVar8 == 0) break;
            iVar3 = FUN_1813fe630(lVar8,iVar10,DAT_182ebe118);
            fVar11 = (float)FUN_181428f50(lVar7,iVar10,DAT_182ee41f0);
            dVar13 = (double)MathUtility__Lim((double)(fVar11 + (float)iVar3),0);
            FUN_181409950(lVar8,iVar10,(int)dVar13,DAT_182ebe2c8);
          }
          iVar10 = iVar10 + 1;
          lVar8 = *(longlong *)(param_1 + 0x18);
        }
      }
    }
  }
LAB_18038dee0:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

