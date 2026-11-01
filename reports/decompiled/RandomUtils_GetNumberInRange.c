
int RandomUtils__GetNumberInRange(longlong param_1)

{
  char cVar1;
  int iVar2;
  int iVar3;
  int iVar4;
  longlong lVar5;
  undefined8 uVar6;
  bool bVar7;
  float fVar8;
  float fVar9;
  double dVar10;
  float local_res8 [2];
  
  if (DAT_18306018e == '\0') {
    FUN_1802334a0(&DAT_182ebd1e8);
    FUN_1802334a0(&DAT_182ea8e40);
    FUN_1802334a0(&DAT_182ec57e8);
    FUN_1802334a0(&DAT_182eeb4d0);
    DAT_18306018e = '\x01';
  }
  local_res8[0] = 0.0;
  cVar1 = System_String__IsNullOrEmpty(param_1,0);
  if (cVar1 != '\0') {
    uVar6 = System_String__Concat(DAT_182eeb4d0,param_1,0);
    if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    UnityEngine_Debug__LogError(uVar6,0);
    return 0;
  }
  cVar1 = System_Single__TryParse(param_1,local_res8);
  fVar8 = local_res8[0];
  if (cVar1 != '\0') {
    if (DAT_18305f9b5 == '\0') {
      FUN_1802334a0(&DAT_182e7eb28);
      DAT_18305f9b5 = '\x01';
    }
    if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    dVar10 = (double)FUN_1802d10b0((double)fVar8);
    fVar8 = (float)FUN_1802d16c0(fVar8,0x3f800000);
    if (1.0 <= fVar8) {
      bVar7 = true;
    }
    else if (fVar8 <= 0.0) {
      bVar7 = false;
    }
    else {
      fVar9 = (float)UnityEngine_Random__get_value(0);
      bVar7 = fVar9 < fVar8;
    }
    return (int)dVar10 + (uint)bVar7;
  }
  if (param_1 != 0) {
    cVar1 = System_String__StartsWith(param_1,DAT_182ec57e8,0);
    if (cVar1 == '\0') {
      iVar4 = 1;
    }
    else {
      param_1 = System_String__Substring(param_1,1,0);
      if (param_1 == 0) goto LAB_1804740ee;
      iVar4 = -1;
    }
    cVar1 = System_String__Contains(param_1,DAT_182ec57e8,0);
    if (cVar1 != '\0') {
      lVar5 = System_String__Split(param_1,0x2d,0,0);
      if (lVar5 == 0) goto LAB_1804740ee;
      if (*(int *)(lVar5 + 0x18) == 2) {
        if ((*(int *)(lVar5 + 0x18) != 0) &&
           (iVar2 = System_Int32__Parse(*(undefined8 *)(lVar5 + 0x20),0),
           1 < *(uint *)(lVar5 + 0x18))) {
          iVar3 = System_Int32__Parse(*(undefined8 *)(lVar5 + 0x28),0);
          if ((iVar2 * iVar4 == 0) && (iVar3 == 0x7fffffff)) {
            fVar8 = (float)UnityEngine_Random__get_value(0);
            if (DAT_18305f9b5 == '\0') {
              FUN_1802334a0(&DAT_182e7eb28);
              DAT_18305f9b5 = '\x01';
            }
          }
          else {
            iVar4 = UnityEngine_Random__Range(iVar2 * iVar4,iVar3 + 1,0);
            if (DAT_18305f9b5 == '\0') {
              FUN_1802334a0(&DAT_182e7eb28);
              DAT_18305f9b5 = '\x01';
            }
            fVar8 = (float)iVar4;
          }
          if (*(int *)(DAT_182e7eb28 + 0xe0) == 0) {
            il2cpp_runtime_class_init();
          }
          dVar10 = (double)FUN_1802d10b0((double)fVar8);
          return (int)dVar10;
        }
                    /* WARNING: Subroutine does not return */
        FUN_180233670();
      }
    }
    uVar6 = System_String__Concat(DAT_182ea8e40,param_1,0);
    if (*(int *)(DAT_182ebd1e8 + 0xe0) == 0) {
      il2cpp_runtime_class_init();
    }
    UnityEngine_Debug__LogError(uVar6,0);
    return 0;
  }
LAB_1804740ee:
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

