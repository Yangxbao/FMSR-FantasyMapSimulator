
undefined8
BurgsAndStateGenerator__<ExpandProvinces>g__getTypeCost_27_3(int param_1,undefined8 param_2)

{
  char cVar1;
  
  if (DAT_183060255 == '\0') {
    FUN_1802334a0(&DAT_182ea61f0);
    FUN_1802334a0(&DAT_182ef97d8);
    FUN_1802334a0(&DAT_182eb5788);
    DAT_183060255 = '\x01';
  }
  if (param_1 == 1) {
    cVar1 = System_String__Equals(param_2,DAT_182ea61f0,0);
    if ((cVar1 == '\0') && (cVar1 = System_String__Equals(param_2,DAT_182ef97d8,0), cVar1 == '\0'))
    {
      cVar1 = System_String__Equals(param_2,DAT_182eb5788,0);
      if (cVar1 == '\0') {
        return 0x41a00000;
      }
      return 0x42700000;
    }
  }
  else {
    if (param_1 == 2) {
      cVar1 = System_String__Equals(param_2,DAT_182ea61f0,0);
      if ((cVar1 == '\0') && (cVar1 = System_String__Equals(param_2,DAT_182eb5788,0), cVar1 == '\0')
         ) {
        return 0;
      }
      return 0x41f00000;
    }
    if (param_1 != -1) {
      cVar1 = System_String__Equals(param_2,DAT_182ea61f0,0);
      if ((cVar1 == '\0') && (cVar1 = System_String__Equals(param_2,DAT_182ef97d8,0), cVar1 == '\0')
         ) {
        return 0;
      }
      return 0x42c80000;
    }
  }
  return 0;
}

