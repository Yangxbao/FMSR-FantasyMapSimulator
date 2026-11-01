
undefined8 HeightMapGenerator__GetPointInRange(longlong param_1,float param_2)

{
  char cVar1;
  longlong lVar2;
  undefined8 uVar3;
  float fVar4;
  float fVar5;
  float local_res8 [6];
  float local_res20 [2];
  
  if (DAT_18305fba2 == '\0') {
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182edc188);
    FUN_1802334a0(&DAT_182eeb400);
    DAT_18305fba2 = '\x01';
  }
  local_res8[0] = 0.0;
  local_res20[0] = 0.0;
  fVar4 = 0.0;
  cVar1 = System_String__IsNullOrEmpty(param_1,0);
  if (cVar1 != '\0') {
    if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    UnityEngine_Debug__LogError(DAT_182eeb400,0);
    return 0;
  }
  if ((param_1 == 0) || (lVar2 = System_String__Split(param_1,0x2d,0,0), lVar2 == 0)) {
                    /* WARNING: Subroutine does not return */
    FUN_180233680();
  }
  if (*(longlong *)(lVar2 + 0x18) != 0) {
    if (*(int *)(lVar2 + 0x18) == 0) goto LAB_18038c430;
    cVar1 = System_Single__TryParse(*(undefined8 *)(lVar2 + 0x20),local_res8,0);
    if (cVar1 != '\0') {
      fVar4 = local_res8[0] / 100.0;
    }
  }
  fVar5 = fVar4;
  if (1 < (int)*(uint *)(lVar2 + 0x18)) {
    if (*(uint *)(lVar2 + 0x18) < 2) {
LAB_18038c430:
                    /* WARNING: Subroutine does not return */
      FUN_180233670();
    }
    cVar1 = System_Single__TryParse(*(undefined8 *)(lVar2 + 0x28),local_res20,0);
    if (cVar1 != '\0') {
      fVar5 = local_res20[0] / 100.0;
    }
  }
  if (*(int *)(DAT_182edc188 + 0xe0) == 0) {
    il2cpp_runtime_class_init();
  }
  uVar3 = UnityEngine_Random__Range(fVar4 * param_2,fVar5 * param_2,0);
  return uVar3;
}

