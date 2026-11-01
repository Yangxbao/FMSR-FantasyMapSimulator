
void HeightMapGenerator___cctor(void)

{
  longlong lVar1;
  
  if (DAT_18305fba8 == '\0') {
    FUN_1802334a0(&DAT_182efb608);
    FUN_1802334a0(&DAT_182efb460);
    FUN_1802334a0(&DAT_182ef36d8);
    FUN_1802334a0(&DAT_182edc188);
    DAT_18305fba8 = '\x01';
  }
  lVar1 = thunk_FUN_1802a5470(DAT_182ef36d8);
  if (lVar1 != 0) {
    FUN_1810c1fc0(lVar1,DAT_182efb460);
    FUN_1810e28d0(lVar1,1000,0x3f6e147b,DAT_182efb608);
    FUN_1810e28d0(lVar1,2000,0x3f733333,DAT_182efb608);
    FUN_1810e28d0(lVar1,5000,0x3f7851ec,DAT_182efb608);
    FUN_1810e28d0(lVar1,10000,0x3f68f5c3,DAT_182efb608);
    FUN_1810e28d0(lVar1,20000,0x3f7d70a4,DAT_182efb608);
    FUN_1810e28d0(lVar1,30000,0x3f7db22d,DAT_182efb608);
    FUN_1810e28d0(lVar1,40000,0x3f7e353f,DAT_182efb608);
    FUN_1810e28d0(lVar1,50000,0x3f7e76c9,DAT_182efb608);
    FUN_1810e28d0(lVar1,60000,0x3f7eb852,DAT_182efb608);
    FUN_1810e28d0(lVar1,70000,0x3f7ed917,DAT_182efb608);
    FUN_1810e28d0(lVar1,80000,0x3f7ef9db,DAT_182efb608);
    FUN_1810e28d0(lVar1,90000,0x3f7f1412,DAT_182efb608);
    FUN_1810e28d0(lVar1,100000,0x3f7f4f0e,DAT_182efb608);
    **(longlong **)(DAT_182edc188 + 0xb8) = lVar1;
    FUN_180232f70(*(undefined8 *)(DAT_182edc188 + 0xb8),lVar1);
    lVar1 = thunk_FUN_1802a5470(DAT_182ef36d8);
    if (lVar1 != 0) {
      FUN_1810c1fc0(lVar1,DAT_182efb460);
      FUN_1810e28d0(lVar1,1000,0x3f400000,DAT_182efb608);
      FUN_1810e28d0(lVar1,2000,0x3f451eb8,DAT_182efb608);
      FUN_1810e28d0(lVar1,5000,0x3f4a3d71,DAT_182efb608);
      FUN_1810e28d0(lVar1,10000,0x3f4f5c29,DAT_182efb608);
      FUN_1810e28d0(lVar1,20000,0x3f51eb85,DAT_182efb608);
      FUN_1810e28d0(lVar1,30000,0x3f547ae1,DAT_182efb608);
      FUN_1810e28d0(lVar1,40000,0x3f570a3d,DAT_182efb608);
      FUN_1810e28d0(lVar1,50000,0x3f5c28f6,DAT_182efb608);
      FUN_1810e28d0(lVar1,60000,0x3f5eb852,DAT_182efb608);
      FUN_1810e28d0(lVar1,70000,0x3f6147ae,DAT_182efb608);
      FUN_1810e28d0(lVar1,80000,0x3f68f5c3,DAT_182efb608);
      FUN_1810e28d0(lVar1,90000,0x3f6b851f,DAT_182efb608);
      FUN_1810e28d0(lVar1,100000,0x3f6e147b,DAT_182efb608);
      *(longlong *)(*(longlong *)(DAT_182edc188 + 0xb8) + 8) = lVar1;
      FUN_180232f70(*(longlong *)(DAT_182edc188 + 0xb8) + 8,lVar1);
      return;
    }
  }
                    /* WARNING: Subroutine does not return */
  FUN_180233680();
}

