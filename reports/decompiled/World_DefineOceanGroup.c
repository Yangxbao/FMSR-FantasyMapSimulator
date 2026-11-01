
undefined8 World__DefineOceanGroup(longlong param_1,int param_2)

{
  undefined8 uVar1;
  
  if (DAT_183060fab == '\0') {
    FUN_1802334a0(&DAT_182e86b60);
    FUN_1802334a0(&DAT_182eb81b8);
    FUN_1802334a0(&DAT_182ef5518);
    DAT_183060fab = '\x01';
  }
  if (param_2 <= *(int *)(param_1 + 0x250) / 0x19) {
    uVar1 = DAT_182e86b60;
    if (param_2 <= *(int *)(param_1 + 0x250) / 100) {
      uVar1 = DAT_182eb81b8;
    }
    return uVar1;
  }
  return DAT_182ef5518;
}

