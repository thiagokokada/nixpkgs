# Generated using:  ./generate-sdk-packages.sh macos 11.0.1

{ applePackage', callPackage }:

{
Csu = applePackage' "Csu" "88" "macos-11.0.1" "1lzp9x8iv60c2h12q2s89nf49b5hvpqq4a9li44zr2fxszn8lqxh" {};
ICU = callPackage ./ICU/package.nix { };
PowerManagement = applePackage' "PowerManagement" "1132.50.3" "macos-11.0.1" "1sb2nz92vdf6v3h17ry0vgw0z9zsva82lhdrhsf3k60jhfw1fi2v" {};
adv_cmds = applePackage' "adv_cmds" "176" "macos-11.0.1" "0sskwl3jc7llbrlyd1i7qlb03yhm1xkbxd1k9xhh7f9wqhlzq31j" {};
basic_cmds = applePackage' "basic_cmds" "55" "macos-11.0.1" "1913pzk376zfap2fwmrb233rkn4h4l2c65nd7s8ixvrz1r7cz0q5" {};
bootstrap_cmds = callPackage ./bootstrap_cmds/package.nix { };
copyfile = applePackage' "copyfile" "173.40.2" "macos-11.0.1" "1j20909inn2iw8n51b8vk551wznfi3bhfziy8nbv08qj5lk50m04" {};
diskdev_cmds = applePackage' "diskdev_cmds" "667.40.1" "macos-11.0.1" "0wr60vyvgkbc4wyldnsqas0xss2k1fgmbdk3vnhj6v6jqa98l1ny" {};
file_cmds = applePackage' "file_cmds" "321.40.3" "macos-11.0.1" "0p077lnbcy8266m03a0fssj4214bjxh88y3qkspnzcvi0g84k43q" {};
libdispatch = applePackage' "libdispatch" "1271.40.12" "macos-11.0.1" "1ck5srcjapg18vqb8wl08gacs7ndc6xr067qjn3ngx39q1jdcywz" {};
libmalloc = applePackage' "libmalloc" "317.40.8" "macos-11.0.1" "sha256-Tdhb0mq3w4Hwvp3xHB79Vr22hCOQK6h28HCsd7jvITI=" {};
libplatform = applePackage' "libplatform" "254.40.4" "macos-11.0.1" "1qf3ri0yd8b1xjln1j1gyx7ks6k3a2jhd63blyvfby75y9s7flky" {};
libpthread = applePackage' "libpthread" "454.40.3" "macos-11.0.1" "0zljbw8mpb80n1if65hhi9lkgwbgjr8vc9wvf7q1nl3mzyl35f8p" {};
libresolv = applePackage' "libresolv" "68" "macos-11.0.1" "045ahh8nvaam9whryc2f5g5xagwp7d187r80kcff82snp5p66aq1" {};
libunwind = applePackage' "libunwind" "200.10" "macos-11.0.1" "0wa4ssr7skn5j0ncm1rigd56qmbs982zvwr3qpjn28krwp8wvigd" {};
libutil = applePackage' "libutil" "58.40.2" "macos-11.0.1" "11s0vizk7bg0k0yjx21j8vaji4j4vk57131qbp07i9lpksb3bcy4" {};
mDNSResponder = applePackage' "mDNSResponder" "1310.40.42" "macos-11.0.1" "0xxrqqbqsf0pagfs1yzwfbwf7lhr0sns97k18y7kh4ri0p09h44c" {};
network_cmds = applePackage' "network_cmds" "606.40.2" "macos-11.0.1" "1jsy13nraarafq6wmgh3wyir8wrwfra148xsjns7cw7q5xn40a1w" {};
objc4 = applePackage' "objc4" "818.2" "macos-11.0.1" "0m8mk1qd18wqjfn2jsq2lx6fxvllhmadmvz11jzg8vjw8pq91nw2" {};
ppp = applePackage' "ppp" "877.40.2" "macos-11.0.1" "06xznc77j45zzi12m4cmr3jj853qlc8dbmynbg1z6m9qf5phdbgk" {};
removefile = applePackage' "removefile" "49.40.3" "macos-11.0.1" "0870ihxpmvj8ggaycwlismbgbw9768lz7w6mc9vxf8l6nlc43z4f" {};
shell_cmds = applePackage' "shell_cmds" "216.40.4" "macos-11.0.1" "0wbysc9lwf1xgl686r3yn95rndcmqlp17zc1ig9gsl5fxyy5bghh" {};
text_cmds = applePackage' "text_cmds" "106" "macos-11.0.1" "17fn35m6i866zjrf8da6cq6crydp6vp4zq0aaab243rv1fx303yy" {};
top = applePackage' "top" "129" "macos-11.0.1" "0d9pqmv3mwkfcv7c05hfvnvnn4rbsl92plr5hsazp854pshzqw2k" {};
xnu = applePackage' "xnu" "7195.50.7.100.1" "macos-11.0.1" "11zjmpw11rcc6a0xlbwramra1rsr65s4ypnxwpajgbr2c657lipl" {};
}
