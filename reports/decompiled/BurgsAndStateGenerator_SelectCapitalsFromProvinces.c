
longlong BurgsAndStateGenerator__SelectCapitalsFromProvinces(longlong param_1)

{
  undefined8 uVar1;
  longlong lVar2;
  longlong *plVar3;
  char cVar4;
  uint uVar5;
  longlong lVar6;
  longlong lVar7;
  longlong lVar8;
  longlong lVar9;
  undefined8 *puVar10;
  ushort uVar11;
  ulonglong uVar12;
  int iVar13;
  int iVar14;
  float fVar15;
  undefined4 extraout_XMM0_Dc;
  undefined4 extraout_XMM0_Dd;
  undefined1 auVar16 [16];
  double dVar17;
  undefined1 unaff_XMM6 [16];
  undefined1 auVar18 [16];
  int local_104;
  longlong *local_f8;
  undefined8 local_f0;
  longlong **local_e8;
  undefined8 local_e0;
  longlong local_d8;
  longlong local_d0;
  longlong local_c8;
  undefined8 local_c0;
  undefined8 uStack_b8;
  longlong local_b0;
  longlong local_a8;
  undefined4 local_90;
  undefined4 uStack_8c;
  undefined4 uStack_88;
  undefined4 uStack_84;
  longlong local_80;
  
  if (DAT_18306022d == '\0') {
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182e755f0);
    FUN_1802334a0(&DAT_182ee39f8);
    FUN_1802334a0(&DAT_182ee3ac8);
    FUN_1802334a0(&DAT_182ee3ba0);
    FUN_1802334a0(&DAT_182ee2ed8);
    FUN_1802334a0(&DAT_182eba260);
    FUN_1802334a0(&DAT_182ec1e58);
    FUN_1802334a0(&DAT_182ee42b0);
    FUN_1802334a0(&DAT_182ebcf70);
    FUN_1802334a0(&DAT_182e99aa8);
    FUN_1802334a0(&DAT_182e99c48);
    FUN_1802334a0(&DAT_182e99d18);
    FUN_1802334a0(&DAT_182ebcce8);
    FUN_1802334a0(&DAT_182e99908);
    FUN_1802334a0(&DAT_182ee6c18);
    FUN_1802334a0(&DAT_182e99de8);
    FUN_1802334a0(&DAT_182ebe040);
    FUN_1802334a0(&DAT_182e99eb8);
    FUN_1802334a0(&DAT_182ebe118);
    FUN_1802334a0(&DAT_182edbc38);
    FUN_1802334a0(&DAT_182ed5398);
    FUN_1802334a0(&DAT_182e7eb28);
    FUN_1802334a0(&DAT_182ebbdf8);
    FUN_1802334a0(&DAT_182edbcd0);
    FUN_1802334a0(&DAT_182eb8d80);
    DAT_18306022d = '\x01';
  }
  local_e0 = 0;
  local_c0 = 0;
  uStack_b8 = 0;
  local_b0 = 0;
  local_f8 = (longlong *)0x0;
  lVar6 = *(longlong *)(param_1 + 0x10);
  if (lVar6 != 0) {
    lVar9 = *(longlong *)(lVar6 + 0x270);
    lVar2 = *(longlong *)(lVar6 + 0x148);
    local_104 = *(int *)(param_1 + 0x18);
    iVar14 = *(int *)(lVar6 + 0x138);
    iVar13 = *(int *)(lVar6 + 0x13c);
    if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    iVar13 = iVar13 * iVar14;
    auVar16._0_8_ = (double)(iVar13 / local_104);
    auVar16._8_8_ = 0;
    if (auVar16._0_8_ < 0.0) {
      auVar18._0_8_ =
           (double)FUN_1802d2fa0(SUB84(auVar16._0_8_,0),
                                 (longlong)iVar13 % (longlong)local_104 & 0xffffffff);
      auVar18._8_4_ = extraout_XMM0_Dc;
      auVar18._12_4_ = extraout_XMM0_Dd;
    }
    else {
      auVar18 = sqrtpd(unaff_XMM6,auVar16);
    }
    lVar6 = thunk_FUN_1802a5470(DAT_182ed5398);
    if (lVar6 != 0) {
      FUN_1813e2b90(lVar6,DAT_182e99908);
      lVar7 = thunk_FUN_1802a5470(DAT_182edbc38);
      if (lVar7 != 0) {
        local_d8 = lVar9;
        FUN_1813e2b90(lVar7,DAT_182ebcce8);
        iVar14 = 1;
        if (lVar9 != 0) {
          for (; iVar14 < *(int *)(lVar9 + 0x18); iVar14 = iVar14 + 1) {
            lVar8 = FUN_1813e2d10(lVar9,iVar14,DAT_182e99eb8);
            if (lVar8 == 0) goto LAB_1804946ae;
            if (*(int *)(lVar8 + 0x58) != 0) {
              lVar8 = FUN_1813e2d10(lVar9,iVar14,DAT_182e99eb8);
              if (lVar8 == 0) goto LAB_1804946ae;
              if (*(char *)(lVar8 + 0x66) != '\0') {
                FUN_1800048f0(lVar7,iVar14,DAT_182ebcf70);
              }
            }
          }
          iVar14 = *(int *)(lVar7 + 0x18);
          if (*(int *)(DAT_182ebbdf8 + 0xe0) == 0) {
            il2cpp_runtime_class_init();
          }
          lVar7 = StateManager__get_Instance(0);
          if ((lVar7 != 0) && (*(longlong *)(lVar7 + 0x18) != 0)) {
            local_d0 = lVar2;
            local_c8 = lVar6;
            if (*(int *)(*(longlong *)(lVar7 + 0x18) + 0x18) == 0) {
              local_104 = *(int *)(param_1 + 0x18);
              uVar5 = local_104 - iVar14;
            }
            else {
              uVar5 = (uint)(*(longlong *)(param_1 + 0x20) != 0);
            }
            do {
              dVar17 = auVar18._0_8_;
              do {
                if (((int)uVar5 <= *(int *)(lVar6 + 0x18)) || (dVar17 <= 1.0)) {
                  lVar9 = thunk_FUN_1802a5470(DAT_182ed5398);
                  if (lVar9 == 0) goto LAB_1804946ae;
                  FUN_1813e2b90(lVar9,DAT_182e99908);
                  lVar6 = FUN_180c1a760(lVar6,uVar5,DAT_182e755f0);
                  if (lVar6 == 0) goto LAB_1804946ae;
                  local_f8 = (longlong *)FUN_180002c20(0,DAT_182eba260,lVar6);
                  local_f0 = 0;
                  local_e8 = &local_f8;
                  goto LAB_180494502;
                }
                *(int *)(lVar6 + 0x1c) = *(int *)(lVar6 + 0x1c) + 1;
                iVar14 = *(int *)(lVar6 + 0x18);
                *(undefined4 *)(lVar6 + 0x18) = 0;
                if (0 < iVar14) {
                  System_Array__Clear(*(undefined8 *)(lVar6 + 0x10),0,iVar14,0,uVar5,dVar17);
                }
                for (iVar14 = 1; iVar14 < *(int *)(lVar9 + 0x18); iVar14 = iVar14 + 1) {
                  lVar7 = FUN_1813e2d10(lVar9,iVar14,DAT_182e99eb8);
                  local_a8 = lVar7;
                  if (((lVar2 == 0) || (lVar7 == 0)) || (*(longlong *)(lVar2 + 0xa8) == 0))
                  goto LAB_1804946ae;
                  iVar13 = FUN_1813fe630(*(longlong *)(lVar2 + 0xa8),*(undefined4 *)(lVar7 + 0x38),
                                         DAT_182ebe118);
                  if ((iVar13 == 0) && (*(char *)(lVar7 + 0x66) != '\0')) {
                    if ((*(longlong *)(param_1 + 0x10) == 0) ||
                       (lVar8 = World__GetSite(*(longlong *)(param_1 + 0x10),
                                               *(undefined4 *)(lVar7 + 0x38),0), lVar8 == 0))
                    goto LAB_1804946ae;
                    local_e0 = *(undefined8 *)(lVar8 + 0x10);
                    FUN_1813e0e20(&local_90,lVar6,DAT_182e99d18);
                    local_c0 = CONCAT44(uStack_8c,local_90);
                    uStack_b8 = CONCAT44(uStack_84,uStack_88);
                    local_b0 = local_80;
                    local_f0 = 0;
                    local_e8 = (longlong **)&local_c0;
                    do {
                      cVar4 = FUN_1811ab230(&local_c0,DAT_182ee3ac8);
                      if (cVar4 == '\0') {
                        AISystemState__Start(&local_c0,DAT_182ee39f8);
                        FUN_180304090(lVar6,lVar7,DAT_182e99aa8);
                        goto LAB_180494447;
                      }
                      if (local_b0 == 0) {
                    /* WARNING: Subroutine does not return */
                        FUN_180233680();
                      }
                      if (*(longlong *)(param_1 + 0x10) == 0) {
                    /* WARNING: Subroutine does not return */
                        FUN_180233680();
                      }
                      lVar8 = World__GetSite(*(longlong *)(param_1 + 0x10),
                                             *(undefined4 *)(local_b0 + 0x38),0);
                      if (lVar8 == 0) {
                    /* WARNING: Subroutine does not return */
                        FUN_180233680();
                      }
                      uVar1 = *(undefined8 *)(lVar8 + 0x10);
                      if (*(int *)(DAT_182edbcd0 + 0xe0) == 0) {
                        il2cpp_runtime_class_init();
                      }
                      fVar15 = (float)csDelaunay_Vector2f__DistanceSquare(&local_e0,uVar1);
                    } while (dVar17 * dVar17 <= (double)fVar15);
                    AISystemState__Start(&local_c0);
                  }
LAB_180494447:
                }
              } while (local_104 <= *(int *)(lVar6 + 0x18));
              if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
                il2cpp_runtime_class_init();
              }
              UnityEngine_Debug__LogWarning(DAT_182eb8d80);
              auVar18._0_8_ = dVar17 / 1.2000000476837158;
            } while( true );
          }
        }
      }
    }
  }
LAB_1804946ae:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
LAB_180494502:
  plVar3 = local_f8;
  if (local_f8 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  lVar6 = *local_f8;
  if (*(ushort *)(lVar6 + 0x12a) != 0) {
    uVar11 = 0;
    do {
      if (*(longlong *)(*(longlong *)(lVar6 + 0xb0) + (ulonglong)uVar11 * 0x10) == DAT_182ee42b0) {
        puVar10 = (undefined8 *)
                  ((longlong)*(int *)(*(longlong *)(lVar6 + 0xb0) + 8 + (ulonglong)uVar11 * 0x10) *
                   0x10 + 0x138 + lVar6);
        goto LAB_180494566;
      }
      uVar11 = uVar11 + 1;
    } while (uVar11 < *(ushort *)(lVar6 + 0x12a));
  }
  puVar10 = (undefined8 *)FUN_180254000(local_f8,DAT_182ee42b0,0);
LAB_180494566:
  cVar4 = (*(code *)*puVar10)(plVar3,puVar10[1]);
  plVar3 = local_f8;
  if (cVar4 == '\0') {
    if (local_f8 != (longlong *)0x0) {
      FUN_180002f00(0,DAT_182ee2ed8,local_f8);
    }
    return lVar9;
  }
  if (local_f8 == (longlong *)0x0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  lVar6 = *local_f8;
  if (*(ushort *)(lVar6 + 0x12a) != 0) {
    uVar12 = 0;
    do {
      if (*(longlong *)(*(longlong *)(lVar6 + 0xb0) + uVar12 * 0x10) == DAT_182ec1e58) {
        puVar10 = (undefined8 *)
                  ((longlong)*(int *)(*(longlong *)(lVar6 + 0xb0) + 8 + uVar12 * 0x10) * 0x10 +
                   0x138 + lVar6);
        goto LAB_1804945d2;
      }
      uVar11 = (short)uVar12 + 1;
      uVar12 = (ulonglong)uVar11;
    } while (uVar11 < *(ushort *)(lVar6 + 0x12a));
  }
  puVar10 = (undefined8 *)FUN_180254000(local_f8,DAT_182ec1e58,0);
LAB_1804945d2:
  lVar6 = (*(code *)*puVar10)(plVar3,puVar10[1]);
  if (lVar6 == 0) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  *(undefined4 *)(lVar6 + 0x58) = 1;
  FUN_180304090(lVar9,lVar6);
  goto LAB_180494502;
}

