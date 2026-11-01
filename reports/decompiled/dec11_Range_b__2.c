
void HeightMapGenerator_<>c__DisplayClass15_0__<addRange>b__2(longlong param_1,undefined4 param_2)

{
  longlong lVar1;
  
  if (DAT_18305fbbb == '\0') {
    FUN_1802334a0(&DAT_182ebe118);
    DAT_18305fbbb = '\x01';
  }
  if ((*(longlong *)(param_1 + 0x18) != 0) &&
     (lVar1 = *(longlong *)(*(longlong *)(param_1 + 0x18) + 0x18), lVar1 != 0)) {
    FUN_1813fe630(lVar1,param_2,DAT_182ebe118);
    return;
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

