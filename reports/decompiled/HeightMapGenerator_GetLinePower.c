
undefined4 HeightMapGenerator__GetLinePower(undefined4 param_1)

{
  longlong lVar1;
  char cVar2;
  undefined4 local_res8 [8];
  
  if (DAT_18305fb98 == '\0') {
    FUN_1802334a0(&DAT_182efba28);
    FUN_1802334a0(&DAT_182edc188);
    DAT_18305fb98 = '\x01';
  }
  local_res8[0] = 0;
  if (*(int *)(DAT_182edc188 + 0xe0) == 0) {
    il2cpp_runtime_class_init(DAT_182edc188);
  }
  lVar1 = *(longlong *)(*(longlong *)(DAT_182edc188 + 0xb8) + 8);
  if (lVar1 != 0) {
    cVar2 = FUN_1810ecd70(lVar1,param_1,local_res8,DAT_182efba28);
    if (cVar2 == '\0') {
      return 0x3f4f5c29;
    }
    return local_res8[0];
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

