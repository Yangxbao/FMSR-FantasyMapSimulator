
undefined8 World__GenerateNoiseHeightmap(longlong param_1,char param_2)

{
  longlong lVar1;
  undefined8 uVar2;
  longlong lVar3;
  longlong lVar4;
  int iVar5;
  uint uVar6;
  undefined4 uVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  float fVar13;
  float fVar14;
  float fVar15;
  undefined4 local_res10 [2];
  
  if (DAT_183060f7e == '\0') {
    FUN_1802334a0(&DAT_182ed1bd8);
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182ecf148);
    FUN_1802334a0(&DAT_182ee4f30);
    FUN_1802334a0(&DAT_182ebe2c8);
    FUN_1802334a0(&DAT_182e8a7c0);
    FUN_1802334a0(&DAT_182ee2b08);
    FUN_1802334a0(&DAT_182e88060);
    DAT_183060f7e = '\x01';
  }
  local_res10[0] = UnityEngine_Random__Range(0,0x7fffffff,0);
  if (param_2 != '\0') {
    local_res10[0] = 0xf81da6e;
  }
  uVar7 = local_res10[0];
  lVar1 = thunk_FUN_1802a5470(DAT_182ecf148);
  if (lVar1 != 0) {
    FastNoiseLite___ctor(lVar1,uVar7,0);
    uVar2 = System_Int32__ToString(local_res10,0);
    uVar2 = System_String__Concat(DAT_182e88060,uVar2,0);
    if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    UnityEngine_Debug__Log(uVar2,0);
    FastNoiseLite__SetNoiseType(lVar1,0,0);
    *(undefined4 *)(lVar1 + 0x14) = *(undefined4 *)(param_1 + 0x3c8);
    *(undefined4 *)(lVar1 + 0x24) = 1;
    FastNoiseLite__SetFractalGain(lVar1,*(undefined4 *)(param_1 + 0x3d4),0);
    FastNoiseLite__SetFractalOctaves(lVar1,*(undefined4 *)(param_1 + 0x3cc),0);
    *(undefined4 *)(lVar1 + 0x2c) = *(undefined4 *)(param_1 + 0x3d0);
    uVar7 = UnityEngine_Random__Range();
    *(undefined4 *)(param_1 + 0x3c8) = uVar7;
    uVar7 = UnityEngine_Random__Range();
    *(undefined4 *)(param_1 + 0x3d8) = uVar7;
    uVar7 = UnityEngine_Random__Range(5,8,0);
    *(undefined4 *)(param_1 + 0x3cc) = uVar7;
    if ((*(longlong *)(param_1 + 0x2d0) != 0) &&
       (lVar3 = csDelaunay_Voronoi__get_Sites(*(longlong *)(param_1 + 0x2d0),0), lVar3 != 0)) {
      lVar4 = FUN_180232fe0(DAT_182e8a7c0,*(undefined4 *)(lVar3 + 0x18));
      fVar15 = 3.4028235e+38;
      lVar3 = *(longlong *)(param_1 + 0x2d0);
      fVar12 = -3.4028235e+38;
      iVar5 = 0;
      fVar10 = 3.4028235e+38;
      fVar14 = -3.4028235e+38;
      while( true ) {
        if ((lVar3 == 0) || (lVar3 = csDelaunay_Voronoi__get_Sites(lVar3,0), lVar3 == 0))
        goto LAB_1806b1fed;
        if (*(int *)(lVar3 + 0x18) <= iVar5) break;
        lVar3 = World__GetSite(param_1,iVar5,0);
        if (lVar3 == 0) goto LAB_1806b1fed;
        if (*(float *)(lVar3 + 0x10) <= fVar15) {
          fVar15 = *(float *)(lVar3 + 0x10);
        }
        if (*(float *)(lVar3 + 0x14) <= fVar10) {
          fVar10 = *(float *)(lVar3 + 0x14);
        }
        if (fVar12 <= *(float *)(lVar3 + 0x10)) {
          fVar12 = *(float *)(lVar3 + 0x10);
        }
        if (fVar14 <= *(float *)(lVar3 + 0x14)) {
          fVar14 = *(float *)(lVar3 + 0x14);
        }
        lVar3 = *(longlong *)(param_1 + 0x2d0);
        iVar5 = iVar5 + 1;
      }
      fVar13 = fVar12 - fVar15;
      if (fVar12 - fVar15 <= fVar14 - fVar10) {
        fVar13 = fVar14 - fVar10;
      }
      lVar3 = *(longlong *)(param_1 + 0x2d0);
      if (lVar3 != 0) {
        uVar6 = 0;
        goto LAB_1806b1cc2;
      }
    }
  }
LAB_1806b1fed:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
LAB_1806b1cc2:
  lVar3 = csDelaunay_Voronoi__get_Sites(lVar3,0);
  if (lVar3 == 0) goto LAB_1806b1fed;
  if (*(int *)(lVar3 + 0x18) <= (int)uVar6) {
    if (lVar4 != 0) {
      lVar1 = System_CharEnumerator__Clone(lVar4,0);
      uVar2 = DAT_182e8a7c0;
      if (lVar1 != 0) {
        lVar3 = thunk_FUN_1802a41d0(lVar1,DAT_182e8a7c0);
        if (lVar3 == 0) {
                    /* WARNING: Subroutine does not return */
          FUN_180232fa0(lVar1,uVar2);
        }
        FUN_180b8ee60(lVar3,DAT_182ed1bd8);
        uVar6 = (uint)((float)*(int *)(lVar3 + 0x18) * *(float *)(param_1 + 0x3d8));
        if (*(uint *)(lVar3 + 0x18) <= uVar6) goto LAB_1806b1fe7;
        fVar12 = *(float *)(lVar3 + 0x20 + (longlong)(int)uVar6 * 4);
        uVar6 = 0;
        goto LAB_1806b1e50;
      }
      FUN_180b8ee60(0,DAT_182ed1bd8);
    }
    goto LAB_1806b1fed;
  }
  lVar3 = World__GetSite(param_1,uVar6,0);
  if (lVar3 == 0) goto LAB_1806b1fed;
  fVar8 = (float)FastNoiseLite__GetNoise
                           (lVar1,*(undefined4 *)(lVar3 + 0x10),*(undefined4 *)(lVar3 + 0x14),0);
  fVar11 = ABS(*(float *)(lVar3 + 0x14) - (fVar14 + fVar10) * 0.5);
  fVar9 = ABS(*(float *)(lVar3 + 0x10) - (fVar12 + fVar15) * 0.5);
  if (fVar9 <= fVar11) {
    fVar9 = fVar11;
  }
  fVar9 = (float)FUN_1802d1a20(fVar9 / (fVar13 * 0.5),*(undefined4 *)(param_1 + 0x3dc));
  fVar9 = (1.0 - fVar9) * 1.5;
  if (fVar9 < 0.0) {
    fVar9 = 0.0;
  }
  else if (1.0 < fVar9) {
    fVar9 = 1.0;
  }
  if (lVar4 == 0) goto LAB_1806b1fed;
  if (*(uint *)(lVar4 + 0x18) <= uVar6) goto LAB_1806b1fe7;
  lVar3 = (longlong)(int)uVar6;
  uVar6 = uVar6 + 1;
  *(float *)(lVar4 + 0x20 + lVar3 * 4) = fVar8 * fVar9;
  lVar3 = *(longlong *)(param_1 + 0x2d0);
  if (lVar3 == 0) goto LAB_1806b1fed;
  goto LAB_1806b1cc2;
LAB_1806b1e50:
  if (*(int *)(lVar4 + 0x18) <= (int)uVar6) goto LAB_1806b1f3e;
  if (*(uint *)(lVar4 + 0x18) <= uVar6) {
LAB_1806b1fe7:
                    /* WARNING: Subroutine does not return */
    FUN_180233670();
  }
  if (fVar12 <= *(float *)(lVar4 + 0x20 + (longlong)(int)uVar6 * 4)) {
    if (*(uint *)(lVar4 + 0x18) <= uVar6) goto LAB_1806b1fe7;
    if (*(longlong *)(param_1 + 0x148) == 0) goto LAB_1806b1fed;
    lVar1 = *(longlong *)(*(longlong *)(param_1 + 0x148) + 0x18);
    fVar10 = 20.0;
    fVar14 = (((*(float *)(lVar4 + 0x20 + (longlong)(int)uVar6 * 4) - fVar12) / (1.0 - fVar12)) *
              80.0 + 20.0) * 1.2;
    if ((20.0 <= fVar14) && (fVar10 = fVar14, 100.0 < fVar14)) {
      fVar10 = 100.0;
    }
  }
  else {
    if (*(longlong *)(param_1 + 0x148) == 0) goto LAB_1806b1fed;
    lVar1 = *(longlong *)(*(longlong *)(param_1 + 0x148) + 0x18);
    fVar10 = (*(float *)(lVar4 + 0x20 + (longlong)(int)uVar6 * 4) / fVar12) * 19.0 * 0.8;
    if (fVar10 < 0.0) {
      fVar10 = 0.0;
    }
    else if (19.0 < fVar10) {
      fVar10 = 19.0;
    }
  }
  if (lVar1 == 0) goto LAB_1806b1fed;
  FUN_181409950(lVar1,uVar6,(int)fVar10,DAT_182ebe2c8);
  uVar6 = uVar6 + 1;
  goto LAB_1806b1e50;
LAB_1806b1f3e:
  if (*(longlong *)(param_1 + 0x148) != 0) {
    uVar2 = *(undefined8 *)(*(longlong *)(param_1 + 0x148) + 0x18);
    if (*(int *)(DAT_182ee2b08 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    uVar2 = World__ListToArrayBuffer(uVar2,0);
    *(undefined8 *)(param_1 + 0x3c0) = uVar2;
    FUN_180232f70(param_1 + 0x3c0,uVar2);
    return *(undefined8 *)(param_1 + 0x3c0);
  }
  goto LAB_1806b1fed;
}

