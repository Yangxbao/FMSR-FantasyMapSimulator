
undefined4 * BrushManager__GetColorFromHeight(undefined4 *param_1,longlong param_2,float param_3)

{
  float fVar1;
  undefined4 uVar2;
  undefined4 uVar3;
  undefined4 uVar4;
  float fVar5;
  float fVar6;
  float fVar7;
  float fVar8;
  float fVar9;
  float fVar10;
  float fVar11;
  float fVar12;
  
  fVar5 = *(float *)(param_2 + 0x34);
  if ((*(float *)(param_2 + 0x34) <= param_3) &&
     (fVar5 = *(float *)(param_2 + 0x38), param_3 <= *(float *)(param_2 + 0x38))) {
    fVar5 = param_3;
  }
  fVar5 = (fVar5 - *(float *)(param_2 + 0x34)) /
          (*(float *)(param_2 + 0x38) - *(float *)(param_2 + 0x34));
  if (0.5 < fVar5) {
    fVar1 = *(float *)(param_2 + 0x3c);
    fVar5 = fVar5 - 0.5;
    fVar9 = *(float *)(param_2 + 0x40);
    fVar11 = *(float *)(param_2 + 0x44);
    fVar12 = *(float *)(param_2 + 0x48);
    fVar6 = *(float *)(param_2 + 0x4c);
    fVar7 = *(float *)(param_2 + 0x50);
    fVar8 = *(float *)(param_2 + 0x54);
    fVar10 = *(float *)(param_2 + 0x58);
  }
  else {
    fVar1 = *(float *)(param_2 + 0x4c);
    fVar9 = *(float *)(param_2 + 0x50);
    fVar11 = *(float *)(param_2 + 0x54);
    fVar12 = *(float *)(param_2 + 0x58);
    fVar6 = *(float *)(param_2 + 0x5c);
    fVar7 = *(float *)(param_2 + 0x60);
    fVar8 = *(float *)(param_2 + 100);
    fVar10 = *(float *)(param_2 + 0x68);
  }
  fVar5 = fVar5 + fVar5;
  if (fVar5 < 0.0) {
    fVar5 = 0.0;
  }
  else if (1.0 < fVar5) {
    fVar5 = 1.0;
  }
  uVar2 = UnityEngine_Mathf__GammaToLinearSpace((fVar1 - fVar6) * fVar5 + fVar6,0);
  uVar3 = UnityEngine_Mathf__GammaToLinearSpace((fVar9 - fVar7) * fVar5 + fVar7,0);
  uVar4 = UnityEngine_Mathf__GammaToLinearSpace((fVar11 - fVar8) * fVar5 + fVar8,0);
  *param_1 = uVar2;
  param_1[1] = uVar3;
  param_1[3] = (fVar12 - fVar10) * fVar5 + fVar10;
  param_1[2] = uVar4;
  return param_1;
}

