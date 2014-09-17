BEGIN { print("["); }
{
 if (FNR > 1) {
   print(",")
 };
 printf("  {\"name\":\"%s\"}", $1); 
}
END { print("\n]"); }

