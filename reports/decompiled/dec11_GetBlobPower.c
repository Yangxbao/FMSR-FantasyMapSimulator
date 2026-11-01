
undefined4 HeightMapGenerator__GetBlobPower(undefined4 param_1)

{
  char cVar1;
  undefined4 local_res8 [8];
  
  if (DAT_18305fb99 == '\0') {
    FUN_1802334a0(&DAT_182efba28);
    FUN_1802334a0(&DAT_182edc188);
    DAT_18305fb99 = '\x01';
  }
  local_res8[0] = 0;
  if (*(int *)(DAT_182edc188 + 0xe0) == 0) {
    il2cpp_runtime_class_init(DAT_182edc188);
  }
  if (**(longlong **)(DAT_182edc188 + 0xb8) != 0) {
    cVar1 = FUN_1810ecd70(**(longlong **)(DAT_182edc188 + 0xb8),param_1,local_res8,DAT_182efba28);
    if (cVar1 == '\0') {
      return 0x3f7ae148;
    }
    return local_res8[0];
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

