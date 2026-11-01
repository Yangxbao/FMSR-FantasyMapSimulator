
void HeightMapGenerator__<addPit>g__addOnePit_14_0(longlong param_1,longlong param_2)

{
  ulonglong uVar1;
  char cVar2;
  int iVar3;
  undefined4 uVar4;
  undefined8 uVar5;
  longlong lVar6;
  longlong lVar7;
  longlong lVar8;
  int iVar9;
  float fVar10;
  float fVar11;
  double dVar12;
  undefined8 local_b0;
  undefined8 uStack_a8;
  ulonglong local_a0;
  undefined8 local_98;
  undefined8 uStack_90;
  ulonglong local_88;
  
  if (DAT_18305fbaa == '\0') {
    FUN_1802334a0(&DAT_182ef3668);
    FUN_1802334a0(&DAT_182e7f448);
    FUN_1802334a0(&DAT_182ef20a0);
    FUN_1802334a0(&DAT_182ef2178);
    FUN_1802334a0(&DAT_182ef2248);
    FUN_1802334a0(&DAT_182edc188);
    FUN_1802334a0(&DAT_182ebd480);
    FUN_1802334a0(&DAT_182e98a68);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182e98b38);
    FUN_1802334a0(&DAT_182ecac80);
    FUN_1802334a0(&DAT_182ecad58);
    FUN_1802334a0(&DAT_182eca928);
    FUN_1802334a0(&DAT_182ecafe0);
    FUN_1802334a0(&DAT_182efa948);
    DAT_18305fbaa = '\x01';
  }
  local_b0 = 0;
  uStack_a8 = 0;
  local_a0 = 0;
  if (*(longlong *)(param_1 + 0x10) != 0) {
    uVar5 = FUN_180c097e0(0,*(undefined4 *)(*(longlong *)(param_1 + 0x10) + 0x250),DAT_182ef3668);
    lVar6 = FUN_180c22330(uVar5,DAT_182e7f448);
    iVar9 = 0;
    iVar3 = RandomUtils__GetNumberInRange(*(undefined8 *)(param_2 + 8),0);
    MathUtility__Lim((double)iVar3,0);
    do {
      uVar5 = *(undefined8 *)(param_2 + 0x10);
      if (*(int *)(DAT_182edc188 + 0xe0) == 0) {
        il2cpp_runtime_class_init();
      }
      HeightMapGenerator__GetPointInRange(uVar5);
      HeightMapGenerator__GetPointInRange(*(undefined8 *)(param_2 + 0x18));
      if (*(longlong *)(param_1 + 0x10) == 0) goto LAB_18038e36e;
      uVar4 = World__GetCellIndex();
      if (*(longlong *)(param_1 + 0x18) == 0) goto LAB_18038e36e;
      iVar3 = FUN_1813fe630(*(longlong *)(param_1 + 0x18),uVar4);
    } while ((iVar3 < 0x14) && (iVar9 = iVar9 + 1, iVar9 < 0x32));
    lVar7 = thunk_FUN_1802a5470(DAT_182efa948);
    if (lVar7 != 0) {
      FUN_180defcd0(lVar7,DAT_182eca928);
      FUN_1814ee5f0(lVar7,uVar4,DAT_182ecad58);
      while( true ) {
        if (*(int *)(lVar7 + 0x20) < 1) {
          return;
        }
        uVar4 = FUN_1814ede40(lVar7,DAT_182ecac80);
        fVar10 = (float)FUN_1802d1a20();
        fVar11 = (float)UnityEngine_Random__get_value(0);
        fVar10 = (fVar11 * 0.2 + 0.9) * fVar10;
        if (fVar10 < 1.0) {
          return;
        }
        if ((*(longlong *)(param_1 + 0x10) == 0) ||
           (lVar8 = World__GetNeighborCells(*(longlong *)(param_1 + 0x10),uVar4,0), lVar8 == 0))
        break;
        FUN_1813f96b0(&local_98,lVar8);
        local_b0 = local_98;
        uStack_a8 = uStack_90;
        local_a0 = local_88;
        while (cVar2 = FUN_1811a17e0(&local_b0,DAT_182ef2178), uVar1 = local_a0, cVar2 != '\0') {
          if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
            FUN_180233680();
          }
          cVar2 = FUN_1813fe680(lVar6,local_a0 & 0xffffffff);
          if (cVar2 == '\0') {
            lVar8 = *(longlong *)(param_1 + 0x18);
            if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
              FUN_180233680();
            }
            iVar3 = FUN_1813fe630(lVar8,uVar1 & 0xffffffff,DAT_182ebe118);
            fVar11 = (float)UnityEngine_Random__get_value(0);
            dVar12 = (double)MathUtility__Lim((double)((float)iVar3 - (fVar11 * 0.2 + 0.9) * fVar10)
                                              ,0);
            FUN_181409950(lVar8,uVar1 & 0xffffffff,(int)dVar12,DAT_182ebe2c8);
            FUN_1813fe780(lVar6,uVar1 & 0xffffffff,1,DAT_182e98b38);
            FUN_1814ee5f0(lVar7,uVar1 & 0xffffffff);
          }
        }
        AISystemState__Start(&local_b0,DAT_182ef20a0);
      }
    }
  }
LAB_18038e36e:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

