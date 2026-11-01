
void BurgsAndStateGenerator__<ExpandProvinces>g__getBiomeCost_27_0
               (uint param_1,uint param_2,undefined8 param_3)

{
  longlong lVar1;
  char cVar2;
  
  if (DAT_183060252 == '\0') {
    FUN_1802334a0(&DAT_182ea1000);
    FUN_1802334a0(&DAT_182ec2a18);
    FUN_1802334a0(&DAT_182eb5788);
    DAT_183060252 = '\x01';
  }
  if (param_1 == param_2) {
    return;
  }
  cVar2 = System_String__Equals(param_3,DAT_182ec2a18,0);
  if (cVar2 == '\0') {
    cVar2 = System_String__Equals(param_3,DAT_182eb5788,0);
    if ((cVar2 == '\0') || (4 < param_2 - 5)) {
      if (*(int *)(DAT_182ea1000 + 0xe0) == 0) {
        il2cpp_runtime_class_init(DAT_182ea1000);
      }
      lVar1 = *(longlong *)(*(longlong *)(DAT_182ea1000 + 0xb8) + 0x20);
      if (lVar1 == 0) goto LAB_180495c59;
      if (param_2 < *(uint *)(lVar1 + 0x18)) {
        return;
      }
    }
    else {
      if (*(int *)(DAT_182ea1000 + 0xe0) == 0) {
        il2cpp_runtime_class_init(DAT_182ea1000);
      }
      lVar1 = *(longlong *)(*(longlong *)(DAT_182ea1000 + 0xb8) + 0x20);
      if (lVar1 == 0) {
LAB_180495c59:
                    /* WARNING: Subroutine does not return */
        FUN_180233680();
      }
      if (param_2 < *(uint *)(lVar1 + 0x18)) {
        return;
      }
    }
  }
  else {
    if (*(int *)(DAT_182ea1000 + 0xe0) == 0) {
      il2cpp_runtime_class_init(DAT_182ea1000);
    }
    lVar1 = *(longlong *)(*(longlong *)(DAT_182ea1000 + 0xb8) + 0x20);
    if (lVar1 == 0) goto LAB_180495c59;
    if (param_2 < *(uint *)(lVar1 + 0x18)) {
      return;
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233670();
}

