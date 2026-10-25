FNR==NR {
  if ($0 ~ /^[ \t]*cell[ \t]*\(/) { c=$0; sub(/.*cell[ \t]*\([ \t]*"?/,"",c); sub(/"?[ \t]*\).*/,"",c) }
  else if ($0 ~ /^[ \t]*area[ \t]*:/ && c!="") { a=$0; sub(/.*:[ \t]*/,"",a); sub(/[ \t]*;.*/,"",a); A[c]=a+0; c="" }
  next
}
($1 in A) {
  k="logic"
  if ($2 ~ /CTS/) k="CTS"; else if ($2 ~ /FE_OFC/) k="OFC(buf)"; else if ($2 ~ /FE_PHC|PHC/) k="HOLD(PHC)"; else if ($2 ~ /FE_RC/) k="RC(restruct)"; else if ($2 ~ /FE_/) k="FE_other"
  n++; tot+=A[$1]; N[k]++; S[k]+=A[$1]
}
END { printf "  TOTAL cells=%d area=%.2f\n", n, tot; for (k in N) printf "  %-13s cells=%5d area=%9.2f (%4.1f%%)\n", k, N[k], S[k], 100*S[k]/tot }
