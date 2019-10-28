
<!-- rnb-text-begin -->

---
title: "match"
author: "Maita Schade"
date: "Aug 26, 2019"
output: html_notebook
---


Given a target sample, recoded panel, and possibly previous invites and completes, this notebook produces a new set of panelists to invite, with flexible number of columns (for larger batches).

Make sure we're dealing with a clear space:

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucm0obGlzdCA9IGxzKGFsbCA9IFRSVUUpKVxuYGBgIn0= -->

```r
rm(list = ls(all = TRUE))
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Set the space up. Country is the only thing you should need to set manually, if the files are all set up properly.

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuY291bnRyeSA8LSBcIkFSXCJcbmBgYCJ9 -->

```r
country <- "AR"
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Defining files--make sure the dirs are okay; other than that you shouldn't need to touch this if the file structure is set up properly.

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZGF0YWRpciA8LSBwYXN0ZTAoJ0M6L1VzZXJzL3NjaGFkZW0vQm94IFN5bmMvTEFQT1AgU2hhcmVkL3dvcmtpbmcgZG9jdW1lbnRzL21haXRhL0Nvb3JkaW5hdGlvbi9JREIgT25saW5lIENyaW1lL01hdGNoaW5nIHByb2Nlc3MvRGF0YS8nLGNvdW50cnksJy8nKVxuXG5gYGAifQ== -->

```r
datadir <- paste0('C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Crime/Matching process/Data/',country,'/')

```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiRXJyb3IgaW4gcGFzdGUwKFwiQzovVXNlcnMvc2NoYWRlbS9Cb3ggU3luYy9MQVBPUCBTaGFyZWQvd29ya2luZyBkb2N1bWVudHMvbWFpdGEvQ29vcmRpbmF0aW9uL0lEQiBPbmxpbmUgQ3JpbWUvTWF0Y2hpbmcgcHJvY2Vzcy9EYXRhL1wiLCAgOiBcbiAgb2JqZWN0ICdjb3VudHJ5JyBub3QgZm91bmRcbiJ9 -->

```
Error in paste0("C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/IDB Online Crime/Matching process/Data/",  : 
  object 'country' not found
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->




<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubGlicmFyeSgnTWF0Y2hJdCcpXG5saWJyYXJ5KCdkYXRhLnRhYmxlJylcbmxpYnJhcnkoJ29wZW54bHN4JylcbiMgbGlicmFyeSgnbGFiZWxsZWQnKVxuIyBcbiMgcmVxdWlyZShwbHlyKVxuIyByZXF1aXJlKHJlc2hhcGUyKVxubGlicmFyeShzdHJpbmdyKVxuYGBgIn0= -->

```r
library('MatchIt')
library('data.table')
library('openxlsx')
# library('labelled')
# 
# require(plyr)
# require(reshape2)
library(stringr)
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Load country-specific parameters:

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxucGFyYW1zIDwtIGZyZWFkKHBhcmFtcGF0aCxrZXkgPSBcImNvdW50cnlcIilbY291bnRyeSxdXG50YXJnZXQuZGF0ZSA8LSBwYXJhbXNbLHRhcmdldC5kYXRlXVxucHJpbnQocGFzdGUwKFwiVGFyZ2V0IGRhdGUgaXMgXCIsIHRhcmdldC5kYXRlKSlcbmBgYCJ9 -->

```r
params <- fread(parampath,key = "country")[country,]
target.date <- params[,target.date]
print(paste0("Target date is ", target.date))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFwiVGFyZ2V0IGRhdGUgaXMgMTkxMDEwXCJcbiJ9 -->

```
[1] "Target date is 191010"
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuTlFfaWQgPC0gcGFyYW1zWyxOUV9pZF1cblxuIyBPbiByZXBlYXRlZCBzYW1wbGluZywganVzdCBtYWtlIHN1cmUgdGhhdCB0aGUgcHJldmlvdXMgdGFyZ2V0IGlzIHJlLXVzZWRcbnRhcmdldGZpbGUgPC0gcGFzdGUwKGRhdGFkaXIsIFwic2FtcGxlL1wiLCBjb3VudHJ5LCBcIl90YXJnZXRfXCIsIHRhcmdldC5kYXRlLCBcIi5jc3ZcIilcbmBgYCJ9 -->

```r
NQ_id <- params[,NQ_id]

# On repeated sampling, just make sure that the previous target is re-used
targetfile <- paste0(datadir, "sample/", country, "_target_", target.date, ".csv")
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->





Load data

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxudGFyZ2V0IDwtIGZyZWFkKHRhcmdldGZpbGUpXG50YXJnZXQgPC0gZnJlYWQodGFyZ2V0ZmlsZSwgY29sQ2xhc3NlcyA9IGMoc2FtcGxlSWQ9XCJjaGFyYWN0ZXJcIikpXG50YXJnZXRbLHNhbXBsZUlkOj1zdHJfcGFkKHNhbXBsZUlkLHdpZHRoPTEzLHBhZD1cIjBcIildXG5wYW5lbCA8LSBmcmVhZChwYW5lbGZpbGUpXG5pZihleGlzdHMoXCJyZWN5Y2xlZmlsZVwiKSl7XG4gIHJlY3ljbGUgPC0gZnJlYWQocmVjeWNsZWZpbGUpXG59XG5sZW5ndGgodW5pcXVlKHBhbmVsJFgpKVxuYGBgIn0= -->

```r
target <- fread(targetfile)
target <- fread(targetfile, colClasses = c(sampleId="character"))
target[,sampleId:=str_pad(sampleId,width=13,pad="0")]
panel <- fread(panelfile)
if(exists("recyclefile")){
  recycle <- fread(recyclefile)
}
length(unique(panel$X))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDMzNVxuIn0= -->

```
[1] 335
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubGVuZ3RoKHVuaXF1ZSh0YXJnZXQkWCkpXG5gYGAifQ== -->

```r
length(unique(target$X))
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDI2MVxuIn0= -->

```
[1] 261
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuc2V0LnNlZWQoMjUwMjkxKVxudGFyZ2V0LnByZSA8LSB0YXJnZXRbc2FtcGxlKC5OLDYwMCldXG5oZWFkKHRhcmdldC5wcmUpXG5gYGAifQ== -->

```r
set.seed(250291)
target.pre <- target[sample(.N,600)]
head(target.pre)
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbImRhdGEudGFibGUiLCJkYXRhLmZyYW1lIl0sIm5jb2wiOjEwLCJucm93Ijo2fSwicmRmIjoiSDRzSUFBQUFBQUFBQm4xVHYwOGJNUlQyL1Fwd1Vta2tXQmhBL0FPSmNqOGdSNUdRMHJJd1JLR3RSRk14Z0pPNFNkU0w3N2c3Uk1ZTS9SY3FWdmJ1bmFyS0MxS1h3dFN0M1RwMXE3cTFFdWx6WWgrUlFaejAyZTk5NzN2MnM1L3Z4VzdUczVzMlFzaEFSa0ZEaGdVbUtqemJkOXdORnlGVEIwOURKbHJnOHhCVVMyQndlWkhMUk9CUnhhdFcvY3BXQlQ3SHVTVTl6dytxblBSdnlRMC9BSnFUM3F4eWE5TjNPZW5tcE9Oc0JyNGZLQ1NJZkU5dUJNU2tDb1NtWmQ2RmpCOEFWZ0VlWUJtd0Jtak14Ty9MMVpUMURURnpXQUlQNVJ0S25NK215TlB2aWVzS09MZkk0Nnl1UDErNW1qdGk5Y2FmNE9UNFBhdWZIL3o2Y3Z3cTl4dVg3eTUrRmoreS9mcnYydm9oeS9OcW82aS8ydzFZclRWazFrNkpQZjN3K0hyMDNjdjk3ZUUvOU9seml6MzU5dkxyRDJvcDdWNUlvck15eFFPU2lrTDFFUXpqOGZpdklyVGFJVTVUOFNZa2FYZHdoc3R2RXNoWDVYTE40dVFwVGNuNUZBL2lrT3gxaEc5MkNaVzJnYnRFMGkyYzlZU3RrMXhBQnJFVXhDU2hrdTcxcEZaclN1TTFERGRLUlhOUm5QVWpDalhwUzZKQnMwZlJFb1VvbmxKK2hrNnAzVHVsYjB1dUkvNEozakVrTGt0MlhOcjJkRTl6TE5heXhGb0ZRcnQ5S3M5bmhiaEZRdUVzUWdNbWQxV09rejdONU1VQ201YXpLTU5TWjdlalVES1R3NkdiL3hnbjhLdlhBd0FBIn0= -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["sampleId"],"name":[1],"type":["chr"],"align":["left"]},{"label":["gend"],"name":[2],"type":["int"],"align":["right"]},{"label":["age"],"name":[3],"type":["int"],"align":["right"]},{"label":["bath"],"name":[4],"type":["int"],"align":["right"]},{"label":["ed"],"name":[5],"type":["int"],"align":["right"]},{"label":["emp"],"name":[6],"type":["int"],"align":["right"]},{"label":["pern"],"name":[7],"type":["int"],"align":["right"]},{"label":["hhh"],"name":[8],"type":["int"],"align":["right"]},{"label":["X"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["Y"],"name":[10],"type":["dbl"],"align":["right"]}],"data":[{"1":"0377409000011","2":"2","3":"86","4":"1","5":"2","6":"1","7":"1","8":"1","9":"-58.01810","10":"-35.00340"},{"1":"0333487000041","2":"1","3":"29","4":"1","5":"3","6":"1","7":"6","8":"2","9":"-58.62461","10":"-34.76931"},{"1":"0548334000031","2":"1","3":"51","4":"1","5":"2","6":"1","7":"4","8":"2","9":"-59.18234","10":"-37.33642"},{"1":"0339642000021","2":"1","3":"20","4":"1","5":"2","6":"1","7":"5","8":"2","9":"-58.62461","10":"-34.76931"},{"1":"1168448000021","2":"1","3":"30","4":"1","5":"5","6":"1","7":"2","8":"2","9":"-63.54311","10":"-27.47258"},{"1":"1200439000011","2":"1","3":"79","4":"1","5":"5","6":"3","7":"3","8":"1","9":"-65.21785","10":"-26.83331"}],"options":{"columns":{"min":{},"max":[10],"total":[10]},"rows":{"min":[10],"max":[10],"total":[6]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->

We're using the pre-election sample this time around!

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuIyB0YXJnZXQgPC0gdGFyZ2V0LnByZVxuIyBub3QgaWYgdGhlcmUgYXJlIGFscmVhZHkgaW52aXRlcyBvdXRcbnByZXZpb3VzIDwtIGZyZWFkKHBhc3RlMChkYXRhZGlyLFwicGFuZWwvQVJfc2VsZWN0ZWRfd2F2ZTFfMTkxMDEwLmNzdlwiKSxjb2xDbGFzc2VzID0gYyhzYW1wbGVJZD1cImNoYXJhY3RlclwiKSlcbiMgaGVhZChwcmV2aW91cylcbnRhcmdldCA8LSB0YXJnZXRbc2FtcGxlSWQlaW4lcHJldmlvdXMkc2FtcGxlSWRdXG4jIHN1bSh0YXJnZXQucHJlJHNhbXBsZUlkJWluJXByZXZpb3VzJHNhbXBsZUlkKVxubnJvdyh0YXJnZXQpXG5gYGAifQ== -->

```r
# target <- target.pre
# not if there are already invites out
previous <- fread(paste0(datadir,"panel/AR_selected_wave1_191010.csv"),colClasses = c(sampleId="character"))
# head(previous)
target <- target[sampleId%in%previous$sampleId]
# sum(target.pre$sampleId%in%previous$sampleId)
nrow(target)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDYwMFxuIn0= -->

```
[1] 600
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



Are there exclusions from a prior survey?
If so, remove them from the panel.

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuZGltKHBhbmVsKVxuYGBgIn0= -->

```r
dim(panel)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDIzMjYzMyAgICAgMTBcbiJ9 -->

```
[1] 232633     10
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuaWYgKGV4aXN0cyhcImV4Y2x1ZGVmaWxlXCIpKXtcbiAgcHJpbnQocGFzdGUwKFwiZXhjbHVkaW5nIHByZXZpb3VzIHJlc3BvbmRlbnRzIGZyb20gXCIsZXhjbHVkZWZpbGUpKVxuXG4gICNUaGUgZm9sbG93aW5nIHdpbGwgZGVwZW5kIG9uIHRoZSBmaWxlIHRoYXQgd2UncmUgcmVhZGluZyBleGNsdXNpb25zIGZyb21cbiAgZXhjbHVkZSA8LSBmcmVhZChleGNsdWRlZmlsZSlcbiAgZXhjbHVkZVssXCJwYW5lbElkXCIgOj0gc3Vic3RyKHRpY2tldCwxLDE2KV1cbiAgXG4gICMgUHJ1bmUgcGFuZWwgdG8gZXhjbHVkZSBwcmV2aW91cyByZXNwb25kZW50c1xuICBwYW5lbCA8LSBwYW5lbFshcGFuZWxJZCAlaW4lIGV4Y2x1ZGUkcGFuZWxJZCxdXG4gIFxufVxuZGltKHBhbmVsKVxuYGBgIn0= -->

```r
if (exists("excludefile")){
  print(paste0("excluding previous respondents from ",excludefile))

  #The following will depend on the file that we're reading exclusions from
  exclude <- fread(excludefile)
  exclude[,"panelId" := substr(ticket,1,16)]
  
  # Prune panel to exclude previous respondents
  panel <- panel[!panelId %in% exclude$panelId,]
  
}
dim(panel)
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDIzMjYzMyAgICAgMTBcbiJ9 -->

```
[1] 232633     10
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



Are there previous invites? If so, load them.
Also, prune the panel to just those not previously invited.

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuaWYgKGxlbmd0aChsaXN0LmZpbGVzKHBhdGg9cGFzdGUwKGRhdGFkaXIsXCJwYW5lbC9cIiksIHBhdHRlcm4gPSBcIndhdmVcIikpPjApe1xuICBwcmludChcInByZXZpb3VzIGludml0ZXMgZm91bmRcIilcbiAgIyBQcmludGluZyB3aGF0IGludml0ZXMgYXJlIGNvbnNpZGVyZWRcbiAgY2F0KHBhc3RlMChcIkluY2x1ZGVkIGludml0ZSBmaWxlczogXFxuXCIpKVxuXG4gICMgUmVhZGluZyBpbiBpbnZpdGUgZmlsZXMgZnJvbSBhbGwgd2F2ZXNcbiAgd2F2ZXMgPC0gbGFwcGx5KFxuICAgIGdyZXAoXCJRQ1wiLGxpc3QuZmlsZXMocGF0aD1wYXN0ZTAoZGF0YWRpcixcInBhbmVsL1wiKSwgcGF0dGVybiA9IFwid2F2ZVwiKSxcbiAgICAgICAgIGludmVydCA9IFQsIHZhbHVlID0gVCksIFxuICAgIGZ1bmN0aW9uICh4KXtcbiAgICAgIGNhdChwYXN0ZTAoXCIgICAgXCIseCxcIlxcblwiKSlcbiAgICAjIyBXZSBtYWtlIHN1cmUgdGhlIGluZGl2aWR1YWwgd2F2ZXMgaGF2ZSBkaXN0aW5ndWlzaGFibGUgbmFtZXMgYnkgYXR0YWNoaW5nIHN1ZmZpeGVzXG4gIFxuICAgICAgZGY8LWZyZWFkKHBhc3RlMChkYXRhZGlyLCBcInBhbmVsL1wiLHgpLGNvbENsYXNzZXMgPSBjKHNhbXBsZUlkPVwiY2hhcmFjdGVyXCIpKVxuICAgICAgZGZbLHNhbXBsZUlkIDo9IHN0cl9wYWQoc3RyaW5nID0gc2FtcGxlSWQsIHdpZHRoID0gbWF4KG5jaGFyKHNhbXBsZUlkKSksIHNpZGUgPSBcImxlZnRcIiwgcGFkID0gXCIwXCIpXVxuICAgICAgI2RmWyxncmVwKFwicGFuZWxJZFwiLG5hbWVzKGRmKSx2YWx1ZSA9IFQpXTwtc2FwcGx5KGRmWyxncmVwKFwicGFuZWxJZFwiLG5hbWVzKGRmKSx2YWx1ZSA9IFQpXSwgdG9sb3dlcilcbiAgICAgIG53YXZlPWFzLm51bWVyaWMoc3RyX21hdGNoKHgsIFwid2F2ZShcXFxcZCspXCIpWzJdKVxuICAgICAgc3VmZml4PXBhc3RlMChcIi5cIiwoKG53YXZlLTEpKjUpKzE6KG5jb2woZGYpLTEpKVxuICAgICAgIyBwcmludChzdWZmaXgpXG4gICAgICBuYW1lcyhkZilbZ3JlcChcInBhbmVsSWQuP1wiLG5hbWVzKGRmKSldIDwtIHBhc3RlMChcInBhbmVsSWRcIixzdWZmaXgpXG4gICAgICByZXR1cm4oZGYpXG5cbiAgIH1cbiAgKVxuICBcbiAgIyBUaGUgdGFyZ2V0IGlzIGEgdGFibGUgb2YgdGFyZ2V0IHJlY29yZHMsIHdpdGggc2VsZWN0ZWQgcGFuZWxpc3QgSURzIGZvciBlYWNoIHdhdmVcbiAgdGFyZ2V0LnNlbGVjdCA8LSBSZWR1Y2UoZnVuY3Rpb24oZHRmMSwgZHRmMikge21lcmdlKGR0ZjEsIGR0ZjIsXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGJ5ID0gYyhcInNhbXBsZUlkXCIpLFxuICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICBhbGwueCA9IFRSVUUpfSxcbiAgICAgICAgICAgICAgICAgICB3YXZlcylcbiAgXG4gICMgdGFyZ2V0IDwtIHRhcmdldFtuYW1lcyh0YXJnZXQpWywtZ3JlcChcInRhcmdldElkfFhcIixuYW1lcyh0YXJnZXQpKV1dXG4gIFxuICAjIFwic2VsZWN0ZWRcIiBpcyBhIGxvbmcgbGlzdCBvZiBhbGwgTlEgcGFuZWxpc3RzIHNlbGVjdGVkIGZyb20gb3VyIGVuZFxuICBzZWxlY3RlZC53aWRlIDwtIFJlZHVjZShmdW5jdGlvbihkdGYxLCBkdGYyKSB7bWVyZ2UoZHRmMSwgZHRmMixcbiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgYnkgPSBjKFwic2FtcGxlSWRcIiksXG4gICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIGFsbC54ID0gVFJVRSwgYWxsLnkgPSBUUlVFKX0sXG4gICAgICAgICAgICAgICAgICAgd2F2ZXMpXG4gIHNlbGVjdGVkLndpZGVcbiAgIyBzZWxlY3RlZCA8LSBzZWxlY3RlZF93aWRlW25hbWVzKHNlbGVjdGVkX3dpZGUpWy1ncmVwKFwidGFyZ2V0SWR8WFwiLG5hbWVzKHNlbGVjdGVkX3dpZGUpKV1dXG4gIHNlbGVjdGVkIDwtIG1lbHQoZGF0YSA9IHNlbGVjdGVkLndpZGUsbWVhc3VyZS52YXJzID0gYyhncmVwKFwicGFuZWxJZFwiLG5hbWVzKHNlbGVjdGVkLndpZGUpKSkpXG4gIFxuICBuYW1lcyhzZWxlY3RlZCk8LWMoXCJzYW1wbGVJZFwiLCAgIFwidmFyaWFibGVcIiwgICBcInBhbmVsSWRcIilcbiAgc2VsZWN0ZWRbLGJhdGNoOj0gYXMuaW50ZWdlcihzdHJfbWF0Y2godmFyaWFibGUsXCJcXFxcZFxcXFxkP1wiKSldXG4gIFxuICBzZWxlY3RlZDwtc2VsZWN0ZWRbc2VsZWN0ZWRbLCFpcy5uYShwYW5lbElkKV0sXVxuICAjIHNlbGVjdGVkJHdhdmUgPC0gYXMuaW50ZWdlcihyZWdtYXRjaGVzKHNlbGVjdGVkJHZhcmlhYmxlLCBcbiAgIyAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICByZWdleHByKFwiXFxcXC5cXFxcS1xcXFxkKyRcIixzZWxlY3RlZCR2YXJpYWJsZSxwZXJsPVRSVUUpXG4gICMgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgKVxuICAjICAgICAgICAgICAgICAgICAgICAgICAgICAgICApXG5cblxuICAjIHdoYXQgaXMgZ29pbmcgb24gd2l0aCBtb3JlIHJlbW92YWxzIHRoYW4gcmVjeWNsZWQgSURzP1xuICAjIEkgd291bGQgZXhwZWN0IHRoYXQgdGhlIG51bWJlciBvZiByZWN5Y2xlcyBtaW51cyB0aGUgbnVtYmVyIG9mIGR1cGxpY2F0ZXMgZXF1YWxzIHRoZSByZW1vdmFscy5cbiAgaWYoZXhpc3RzKFwicmVjeWNsZVwiKSl7XG4gICAgIyBSZW1vdmUgd2hvIHdhcyBfbm90XyBpbnZpdGVkXG4gICAgbmFtZXMocmVjeWNsZSlbMV0gPC0gXCJwYW5lbElkXCJcbiAgICBhY3R1YWxseS51c2VkIDwtICghKHNlbGVjdGVkJHBhbmVsSWQlaW4lcmVjeWNsZSRwYW5lbElkKSl8KHNlbGVjdGVkJGJhdGNoPjUpXG4gICAgbnJvdyhzZWxlY3RlZCktc3VtKGFjdHVhbGx5LnVzZWQpXG4gICAgXG4gICAgXG4gICAgaW52aXRlZCA8LSBzZWxlY3RlZFthY3R1YWxseS51c2VkLF1cbiAgICBkaW0oaW52aXRlZClcbiAgfSBlbHNlIHtcbiAgICBpbnZpdGVkIDwtIHNlbGVjdGVkXG4gIH1cbiAgIyBQcnVuZSBwYW5lbCB0byBleGNsdWRlIGludml0ZWRcbiAgcGFuZWwgPC0gcGFuZWxbIXBhbmVsSWQgJWluJSBpbnZpdGVkJHBhbmVsSWQsXVxuICBcbiAgIyBzZXQgd2F2ZVxuICB3YXZlIDwtIGxlbmd0aCh3YXZlcykrMVxuICBcbiAgI0NoZWNrIHRoYXQgdGFyZ2V0LnNlbGVjdCBhbmQgdGFyZ2V0IGFyZSBjb21wYXRpYmxlIChhbmQgbm90aGluZyBnb3Qgc29tZWhvdyBtZXNzZWQgdXAgd2hlbiBmaXhpbmcgdG8gZGVwdClcbiAgI0FyZSB3ZSBva2F5LS1kaWQgd2Ugbm90IG1lc3MgdXAgdGhlIHNhbXBsZSB3aGVuIGZpeGluZyBkZXB0cz9cbiAgaWYoc3VtKCF0YXJnZXQuc2VsZWN0JHNhbXBsZUlkJWluJXRhcmdldCRzYW1wbGVJZCk9PTApe1xuICAgIHRhcmdldCA8LSB0YXJnZXRbc2FtcGxlSWQlaW4ldGFyZ2V0LnNlbGVjdCRzYW1wbGVJZF1cbiAgfVxuICBcblxufSBlbHNlIHt3YXZlIDwtIDF9XG5gYGAifQ== -->

```r
if (length(list.files(path=paste0(datadir,"panel/"), pattern = "wave"))>0){
  print("previous invites found")
  # Printing what invites are considered
  cat(paste0("Included invite files: \n"))

  # Reading in invite files from all waves
  waves <- lapply(
    grep("QC",list.files(path=paste0(datadir,"panel/"), pattern = "wave"),
         invert = T, value = T), 
    function (x){
      cat(paste0("    ",x,"\n"))
    ## We make sure the individual waves have distinguishable names by attaching suffixes
  
      df<-fread(paste0(datadir, "panel/",x),colClasses = c(sampleId="character"))
      df[,sampleId := str_pad(string = sampleId, width = max(nchar(sampleId)), side = "left", pad = "0")]
      #df[,grep("panelId",names(df),value = T)]<-sapply(df[,grep("panelId",names(df),value = T)], tolower)
      nwave=as.numeric(str_match(x, "wave(\\d+)")[2])
      suffix=paste0(".",((nwave-1)*5)+1:(ncol(df)-1))
      # print(suffix)
      names(df)[grep("panelId.?",names(df))] <- paste0("panelId",suffix)
      return(df)

   }
  )
  
  # The target is a table of target records, with selected panelist IDs for each wave
  target.select <- Reduce(function(dtf1, dtf2) {merge(dtf1, dtf2,
                                               by = c("sampleId"),
                                               all.x = TRUE)},
                   waves)
  
  # target <- target[names(target)[,-grep("targetId|X",names(target))]]
  
  # "selected" is a long list of all NQ panelists selected from our end
  selected.wide <- Reduce(function(dtf1, dtf2) {merge(dtf1, dtf2,
                                               by = c("sampleId"),
                                               all.x = TRUE, all.y = TRUE)},
                   waves)
  selected.wide
  # selected <- selected_wide[names(selected_wide)[-grep("targetId|X",names(selected_wide))]]
  selected <- melt(data = selected.wide,measure.vars = c(grep("panelId",names(selected.wide))))
  
  names(selected)<-c("sampleId",   "variable",   "panelId")
  selected[,batch:= as.integer(str_match(variable,"\\d\\d?"))]
  
  selected<-selected[selected[,!is.na(panelId)],]
  # selected$wave <- as.integer(regmatches(selected$variable, 
  #                                        regexpr("\\.\\K\\d+$",selected$variable,perl=TRUE)
  #                                        )
  #                             )


  # what is going on with more removals than recycled IDs?
  # I would expect that the number of recycles minus the number of duplicates equals the removals.
  if(exists("recycle")){
    # Remove who was _not_ invited
    names(recycle)[1] <- "panelId"
    actually.used <- (!(selected$panelId%in%recycle$panelId))|(selected$batch>5)
    nrow(selected)-sum(actually.used)
    
    
    invited <- selected[actually.used,]
    dim(invited)
  } else {
    invited <- selected
  }
  # Prune panel to exclude invited
  panel <- panel[!panelId %in% invited$panelId,]
  
  # set wave
  wave <- length(waves)+1
  
  #Check that target.select and target are compatible (and nothing got somehow messed up when fixing to dept)
  #Are we okay--did we not mess up the sample when fixing depts?
  if(sum(!target.select$sampleId%in%target$sampleId)==0){
    target <- target[sampleId%in%target.select$sampleId]
  }
  

} else {wave <- 1}
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFwicHJldmlvdXMgaW52aXRlcyBmb3VuZFwiXG5JbmNsdWRlZCBpbnZpdGUgZmlsZXM6IFxuICAgIEFSX3NlbGVjdGVkX3dhdmUxXzE5MTAxMC5jc3ZcbiAgICBBUl9zZWxlY3RlZF93YXZlMl8xOTEwMTYuY3N2XG4gICAgQVJfc2VsZWN0ZWRfd2F2ZTNfMTkxMDIzLmNzdlxuIn0= -->

```
[1] "previous invites found"
Included invite files: 
    AR_selected_wave1_191010.csv
    AR_selected_wave2_191016.csv
    AR_selected_wave3_191023.csv
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxud2F2ZVxuYGBgIn0= -->

```r
wave
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDRcbiJ9 -->

```
[1] 4
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->





Are there previous completes? If so, load them.

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuaWYgKGV4aXN0cyhcInJlc3BvbnNlZmlsZVwiKSl7XG4gIHByaW50KFwiY29tcGxldGVzIGZvdW5kIVwiKVxuXG4gICMgIyBcInJlc3BvbmRlZFwiIGNhbiBiZSBsb2FkZWQgc3RyYWlnaHQgZnJvbSBRdWFsdHJpY3MgXG4gIHJlc3BvbmRlZCA8LSBmcmVhZChyZXNwb25zZWZpbGUpXG4gIHJlc3BvbmRlZFssXCJwYW5lbElkXCIgOj0gc3RyX3RvX2xvd2VyKHBpZCldXG4gIHJlc3BvbmRlZCA8LSByZXNwb25kZWRbLSgxOjMpLHBhbmVsSWRdXG5cbiAgIy4uLiBmb3IgaWRlbnRpZnlpbmcgaG93IG1hbnkgdGFyZ2V0cyBoYXZlIGJlZW4gaGl0LCBhdHRhY2ggdG8gZWFjaCByZXNwb25kZW50IGl0cyB1bmlxdWUgU0FNUElEXG4gIHJlc3BvbmRlZCA8LSBzZWxlY3RlZFtwYW5lbElkJWluJXJlc3BvbmRlZF1cbiAgcmVzcG9uZGVkIDwtIHJlc3BvbmRlZFshZHVwbGljYXRlZChwYW5lbElkLGZyb21MYXN0ID0gVFJVRSksXVxuICBcblxuICAgIFxuICAjIENvdW50aW5nIGR1cGxpY2F0ZXMgYnkgY291bnRpbmcgb2NjdXJyZW5jZSBvZiBzYW1wbGVJZCBpbiByZXNwb25kZW50czpcbiAgbnNhbXBfcmVzcCA8LSB0YWJsZShyZXNwb25kZWQkc2FtcGxlSWQpXG4gXG4gIGR1cGVzIDwtIHN1bShuc2FtcF9yZXNwLTEpICBcbiAgZHVwZXNcbiAgXG4gIGxlZ2l0IDwtIG5yb3cocmVzcG9uZGVkKS1kdXBlc1xuXG4gIGNhdChwYXN0ZTAoXCJcXG5EdXBsaWNhdGVzIGluIFwiLCBjb3VudHJ5LCBcIjogXCIsIGR1cGVzLFwiXFxuXCIpKVxuICBjYXQocGFzdGUwKFwiXFxuTGVnaXQgcmVzcG9uc2VzOiBcIiwgbGVnaXQpKVxuXG4gICMgIyBSZXNwb25kZW50cyB0aGF0IHdlcmUgbm90IGludml0ZWQ/XG4gICMgY2F0KHJlc3BvbmRlZFtpcy5uYShyZXNwb25kZWQkU0FNUElEKSxdW1tOUV9pZF1dKVxuICBcbiAgIyMgUHJ1bmUgdGFyZ2V0IHRvIGV4Y2x1ZGUgZmlsbGVkIHNsb3RzXG4gICMgY3JlYXRlIGxpc3Qgb2YgcmVzcG9uZGVudHMgaW4gd2lkZSBzYW1wbGUgaWQgZm9ybWF0LS1hY3R1YWxseSB0aGlzIHNob3VsZG4ndCBiZSBuZWNlc3NhcnkgaGVyZSwgYnV0IGxldCdzIG5vdCBmdXR6IHdpdGggaXQgZm9yIG5vd1xuICBpbnZpdGVkLnJlc3AgPC0gaW52aXRlZFsocGFuZWxJZCAlaW4lIHJlc3BvbmRlZCRwYW5lbElkKSxdICN0aG9zZSB0aGF0IHdlcmUgaW52aXRlZCBhbmQgYWN0dWFsbHkgcmVzcG9uZGVkXG4gIHJlc3BvbmRlZC53aWRlIDwtIGRjYXN0KGludml0ZWQucmVzcCwgLi4uIH4gdmFyaWFibGUpXG4gICMgcmVzcG9uZGVkLndpZGVbc2FtcGxlSWQlaW4lc2FtcGxlSWRbZHVwbGljYXRlZChzYW1wbGVJZCldXVxuICBcbiAgXG4gICMgQ2hlY2sgdGhhdCBubyBzYW1wbGVJZCdzIGFyZSBkdXBsaWNhdGVkOlxuICBpZiAoc3VtKGR1cGxpY2F0ZWQocmVzcG9uZGVkLndpZGUkc2FtcGxlSWQpKSE9IDApe1xuICAgIHByaW50KFwiQWxlcnQhIFNvbWVob3cgeW91IGhhdmUgZHVwbGljYXRlZCBzYW1wbGVJZHMhXCIpXG4gICAgfVxuICBcbiAgIyBrZWVwIG9ubHkgdGFyZ2V0cyB0aGF0IGFyZSBub3QgaW5jbHVkZWQgaW4gcmVzcG9uc2Ugc2V0XG4gIHRhcmdldC5wcnVuZWQgPC0gdGFyZ2V0WyFzYW1wbGVJZCVpbiVyZXNwb25kZWQud2lkZSRzYW1wbGVJZCxdXG4gIGRpbShpbnZpdGVkLnJlc3ApXG4gIGRpbShyZXNwb25kZWQpXG4gIGRpbShyZXNwb25kZWQud2lkZSlcbiAgcHJpbnQoXCJEaW1lbnNpb25zIG9mIHBydW5lZCB0YXJnZXQ6XCIpXG4gIGRpbSh0YXJnZXQucHJ1bmVkKVxufSBlbHNlIHtcbiAgdGFyZ2V0LnBydW5lZCA8LSB0YXJnZXRcbiAgfVxuYGBgIn0= -->

```r
if (exists("responsefile")){
  print("completes found!")

  # # "responded" can be loaded straight from Qualtrics 
  responded <- fread(responsefile)
  responded[,"panelId" := str_to_lower(pid)]
  responded <- responded[-(1:3),panelId]

  #... for identifying how many targets have been hit, attach to each respondent its unique SAMPID
  responded <- selected[panelId%in%responded]
  responded <- responded[!duplicated(panelId,fromLast = TRUE),]
  

    
  # Counting duplicates by counting occurrence of sampleId in respondents:
  nsamp_resp <- table(responded$sampleId)
 
  dupes <- sum(nsamp_resp-1)  
  dupes
  
  legit <- nrow(responded)-dupes

  cat(paste0("\nDuplicates in ", country, ": ", dupes,"\n"))
  cat(paste0("\nLegit responses: ", legit))

  # # Respondents that were not invited?
  # cat(responded[is.na(responded$SAMPID),][[NQ_id]])
  
  ## Prune target to exclude filled slots
  # create list of respondents in wide sample id format--actually this shouldn't be necessary here, but let's not futz with it for now
  invited.resp <- invited[(panelId %in% responded$panelId),] #those that were invited and actually responded
  responded.wide <- dcast(invited.resp, ... ~ variable)
  # responded.wide[sampleId%in%sampleId[duplicated(sampleId)]]
  
  
  # Check that no sampleId's are duplicated:
  if (sum(duplicated(responded.wide$sampleId))!= 0){
    print("Alert! Somehow you have duplicated sampleIds!")
    }
  
  # keep only targets that are not included in response set
  target.pruned <- target[!sampleId%in%responded.wide$sampleId,]
  dim(invited.resp)
  dim(responded)
  dim(responded.wide)
  print("Dimensions of pruned target:")
  dim(target.pruned)
} else {
  target.pruned <- target
  }
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Netquest wanted to know which targets were already complete, so find them and write them out.

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxud3JpdGUuY3N2KHRhcmdldFshc2FtcGxlSWQlaW4ldGFyZ2V0LnBydW5lZCRzYW1wbGVJZCxzYW1wbGVJZF0sXG4gICAgICAgICAgcGFzdGUwKFwiY29tcGxldGVzX1wiLGZvcm1hdChTeXMudGltZSgpLFwiJXklbSVkXCIpLFwiLmNzdlwiKSlcblxuYGBgIn0= -->

```r
write.csv(target[!sampleId%in%target.pruned$sampleId,sampleId],
          paste0("completes_",format(Sys.time(),"%y%m%d"),".csv"))

```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->




Add a treatment into it:

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxucGFuZWxbLCd0cmVhdCc6PSByZXAoMCxucm93KHBhbmVsKSldXG50YXJnZXQucHJ1bmVkWywndHJlYXQnOj1yZXAoMSxucm93KHRhcmdldC5wcnVuZWQpKV1cbmBgYFxuYGBgIn0= -->

```r
```r
panel[,'treat':= rep(0,nrow(panel))]
target.pruned[,'treat':=rep(1,nrow(target.pruned))]
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Now join this data together:

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuYWxsZGF0YSA8LSByYmluZChwYW5lbCwgdGFyZ2V0LnBydW5lZCwgZmlsbD1UKVxuI2ZpbGwgTkFcbmFsbGRhdGFbaXMubmEocGFuZWxJZCkscGFuZWxJZDo9XFw5OTk5OTk5OTk5XFxdXG5hbGxkYXRhW2lzLm5hKHNhbXBsZUlkKSxzYW1wbGVJZDo9XFw5OTk5OTk5OTk5XFxdXG5cbmhlYWQoYWxsZGF0YSlcbmBgYFxuYGBgIn0= -->

```r
```r
alldata <- rbind(panel, target.pruned, fill=T)
#fill NA
alldata[is.na(panelId),panelId:=\9999999999\]
alldata[is.na(sampleId),sampleId:=\9999999999\]

head(alldata)
```
```

<!-- rnb-source-end -->

<!-- rnb-frame-begin eyJtZXRhZGF0YSI6eyJjbGFzc2VzIjpbImRhdGEudGFibGUiLCJkYXRhLmZyYW1lIl0sIm5jb2wiOjEyLCJucm93Ijo2fSwicmRmIjoiSDRzSUFBQUFBQUFBQnJWVFBZalVRQlNlWkRkN2QzRTlWZzg5ckN4VTJHYVgvRzUyTGNSVjhhZTQ0eFNWRlVTWUpMTS9iRElKMlJ4NmhYQ2RyVmdvOW9KZ1lXRWpYRFg0aTVaYWE2SHQyZG1vY09za083T1hpNGRnNGNDWDkrWjdQL1BlbThtbE14MWQ3c2dBZ0FJb2xBUlFrS2dLU3FkWFZNM1VBQ2lLZENlQUlwaEw1QzNxdFVDVk1zWGV4QzAxQWlCbUpBZTNWeWtPVUJ5anFGSHNwemlhaTk4TjNGNU1TOXVXQXBPN3hmT3pCZkJuZlJ6bHY4Um5lNWxQN0dUNXlzdjMzUWNpdVhnd2VQaGw0eFZaT1h6djI2KzNJbGwrV3Z1MFovTWRXZXFzZjd6KzdEWlpPdUlQMXc2ZG04YWQ4amZlL0tpK0p1MjF4ZnVMajYrU2swK001NC91WENZbmpuK3ZidFpma1BiWnUrYy9HMFBTdnJIdncxZXBUV01xYVQyVFFWY1V1a3hOTjJ4WFZSMnJhKzNncmFabUsxcWphZWhLbHJlVWJzdHlkS1ZwV0c2V2Q2R21Rc1d3VE1OU3MzeTMxV2pZanVYU1kvUU1yeHFxMjlKZHN3bHRFL0ord0wrdmJEOXlhN3IrSTdQenNjNUZ3YzA2aGo0YXNjc1cxK2xuUEI3L3pEbEtqZ2RISTFZeEoyVVh4ckRlaldoODNwM25yS1NQYVVJV2V3anpvUmRnRDNIYWhuR2Y2U0thT2lBLzVBNGhpakNuKzMzdUszUzRjbzBwTXlIRXlMdkFVMGh4aEdETU5yTWo2SWNlb2tZQXRuTFZ6Z1JoUEFnd3JWZE1mbHdwMTZZUTVZaktLazc2YzJ0T2Z4VVBhMm96bVFYN0l3QWJwTUJlQk5mTGt6T0xZNVpMWXJsS0NQY0dtTTlDOHFDTlBMYVpwNWVUenJFZVJnUE1HNUVwTzZySFFReTVuK3dFSG1mUzVzRFdiN3c3YmZ5eEJBQUEifQ== -->

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["gend"],"name":[1],"type":["int"],"align":["right"]},{"label":["age"],"name":[2],"type":["int"],"align":["right"]},{"label":["bath"],"name":[3],"type":["int"],"align":["right"]},{"label":["ed"],"name":[4],"type":["int"],"align":["right"]},{"label":["emp"],"name":[5],"type":["int"],"align":["right"]},{"label":["pern"],"name":[6],"type":["int"],"align":["right"]},{"label":["hhh"],"name":[7],"type":["int"],"align":["right"]},{"label":["X"],"name":[8],"type":["dbl"],"align":["right"]},{"label":["Y"],"name":[9],"type":["dbl"],"align":["right"]},{"label":["panelId"],"name":[10],"type":["chr"],"align":["left"]},{"label":["treat"],"name":[11],"type":["dbl"],"align":["right"]},{"label":["sampleId"],"name":[12],"type":["chr"],"align":["left"]}],"data":[{"1":"1","2":"40","3":"1","4":"4","5":"1","6":"1","7":"1","8":"-60.67004","9":"-36.85726","10":"00005234bd11c7f7","11":"0","12":"9999999999"},{"1":"2","2":"21","3":"1","4":"3","5":"1","6":"2","7":"1","8":"-68.35056","9":"-34.94603","10":"00005782b0268430","11":"0","12":"9999999999"},{"1":"1","2":"37","3":"1","4":"4","5":"1","6":"2","7":"1","8":"-64.49334","9":"-33.32973","10":"000070f97c30847d","11":"0","12":"9999999999"},{"1":"2","2":"45","3":"1","4":"3","5":"2","6":"2","7":"1","8":"-61.36077","9":"-30.23029","10":"0000da21a0475471","11":"0","12":"9999999999"},{"1":"2","2":"18","3":"1","4":"1","5":"2","6":"12","7":"2","8":"-58.69143","9":"-34.55128","10":"0000f966bc7d2343","11":"0","12":"9999999999"},{"1":"2","2":"36","3":"1","4":"3","5":"1","6":"3","7":"1","8":"-58.27678","9":"-34.73492","10":"000141d93d58ab5a","11":"0","12":"9999999999"}],"options":{"columns":{"min":{},"max":[10],"total":[12]},"rows":{"min":[10],"max":[10],"total":[6]},"pages":{}}}
  </script>
</div>

<!-- rnb-frame-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Divide target sample into age quantiles (in this case, deciles) and add that to the data:

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuYWdlX3EgPC0gcXVhbnRpbGUodGFyZ2V0JGFnZSxwcm9iID0gc2VxKDAsMSwwLjEpKSAjdGhpcyBpcyB0aGUgZnVsbCB0YXJnZXRcbmFsbGRhdGFbLCdhZ2VfZ3JvdXAnIDo9ICBhcy5pbnRlZ2VyKGN1dChhbGxkYXRhJGFnZSxicmVha3MgPSBhZ2VfcSwgaW5jbHVkZS5sb3dlc3QgPSBUUlVFKSldXG5hbGxkYXRhW2lzLm5hKGFnZV9ncm91cCksYWdlXVxuYGBgXG5gYGAifQ== -->

```r
```r
age_q <- quantile(target$age,prob = seq(0,1,0.1)) #this is the full target
alldata[,'age_group' :=  as.integer(cut(alldata$age,breaks = age_q, include.lowest = TRUE))]
alldata[is.na(age_group),age]
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiIFsxXSAxMDAgMTAwICA5OSAxMDAgIDk5IDEwMCAxMDAgMTAwIDEwMCAgOTkgIDk5IDEwMCAxMDAgMTAwIDEwMFxuIn0= -->

```
 [1] 100 100  99 100  99 100 100 100 100  99  99 100 100 100 100
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuYWxsZGF0YSRhZ2VfZ3JvdXBbaXMubmEoYWxsZGF0YSRhZ2VfZ3JvdXApXSA8LSAxMCAjaGlnaGVzdCBhZ2UtZ3JvdXAgY2FuIGdldCBsb3N0OyBmaWxsIGl0IGluXG5gYGBcbmBgYCJ9 -->

```r
```r
alldata$age_group[is.na(alldata$age_group)] <- 10 #highest age-group can get lost; fill it in
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



Load in matching.vars from recodefile

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxucmVjb2RlX21hcCA8LSBmcmVhZChyZWNvZGVwYXRoKVxubWF0Y2hpbmcudmFycyA8LSB1bmlxdWUocmVjb2RlX21hcCRjb21tb25fdmFyKVxuYGBgXG5gYGAifQ== -->

```r
```r
recode_map <- fread(recodepath)
matching.vars <- unique(recode_map$common_var)
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Now carry out the matching. 

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxubWF0Y2hpbmcuZm9ybSA8LSBhcy5mb3JtdWxhKHBhc3RlMChcInRyZWF0IH4gXCIsIHBhc3RlKG1hdGNoaW5nLnZhcnMsIGNvbGxhcHNlPScgKyAnKSkpXG5gYGAifQ== -->

```r
matching.form <- as.formula(paste0("treat ~ ", paste(matching.vars, collapse=' + ')))
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



We'll have to repeat this process (at least for everything except PS). 
* start empty dataframe initialized with target IDs
* make a copy of the data to alter
* for each i in range:
  + run the matching
  + store the matched IDs
  + store some overall metrics about the match
  + reduce the panel data
* return the match objects


<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxubWF0Y2hSYXRpbyA8LSBmdW5jdGlvbihkYXRhLCBtZXRyaWMsIG4sIGV4YWN0ID0gYygpKXtcbiAgIyBBIHdyYXBwZXIgZm9yIHRoZSBNYXRjaEl0IGZyYW1ld29yayB0byBjYXJyeSBvdXQgYXJiaXRyYXJ5IG51bWJlcnMgb2Ygc3VjY2Vzc2l2ZSBtYXRjaGVzXG4gICMgZGF0YSBtdXN0IGhhdmU6XG4gICMgICAqIHNhbXBsZUlkXG4gICMgICAqIHBhbmVsSWRcbiAgIyAgICogdHJlYXRcbiAgcmVxdWlyZShNYXRjaEl0KVxuICAgIFxuICAjIGFzc2lnbiB0aGUgZGF0YWZyYW1lIHRvIGhvbGQgdGhlIG1hdGNoaW5nIHJlc3VsdHNcbiAgZGYgPC0gZGF0YS5mcmFtZShtYXRyaXgobmNvbD0xLCBucm93PXN1bShkYXRhJHRyZWF0PT0xKSkpXG4gIG5hbWVzKGRmKSA8LSBjKFxcc2FtcGxlSWRcXClcbiAgZGYkc2FtcGxlSWQgPC0gZGF0YSRzYW1wbGVJZFtkYXRhJHRyZWF0PT0xXVxuICBcbiAgIyBhc3NpZ24gdGhlIG9iamVjdCB0byBob2xkIGFsbCB0aGUgbWF0Y2hpbmcgaW5mb3JtYXRpb25cbiAgbWF0Y2hlcyA8LSB2ZWN0b3IoXFxsaXN0XFwsbilcbiAgXG4gICMgbWFrZSBhIGNvcHkgb2YgdGhlIHBhc3NlZC1pbiBkYXRhXG4gIGRhdGEuY29weSA8LSBkYXRhLmZyYW1lKGRhdGEpXG4gIFxuICAjIGxvb3Agb3ZlciB0aGUgbnVtYmVyIG9mIHJlc3BvbmRlbnRzIHBlciB0YXJnZXRcbiAgIyBpZiB0aGVyZSBhcmUgaXNzdWVzLCBjYW4gSSByZWxheCB0aGUgYWdlIGdyb3Vwcz9cbiAgZm9yKGkgaW4gMTpuKXtcbiAgICBwcmludChwYXN0ZSgnaSA9ICcsYXMuY2hhcmFjdGVyKGkpKSlcbiAgICBtIDwtIG1hdGNoaXQobWF0Y2hpbmcuZm9ybSwgXG4gICAgICAgICAgICAgICAgIGRhdGEgPSBkYXRhLmNvcHksIGV4YWN0PWV4YWN0LCBtZXRob2QgPSBcXG5lYXJlc3RcXCwgZGlzdGFuY2UgPSBtZXRyaWMpXG4gICAgY29udHJvbHMgPC0gbWF0Y2guZGF0YShtLCBncm91cD0nY29udHJvbCcpXG4gICAgXG4gICAgdHJ5KHttYXRjaGVzW1tpXV0gPC0gbVxuICAgICAgICBzYW1wbGVpZHMgPC0gZGF0YS5jb3B5W3Jvdy5uYW1lcyhtJG1hdGNoLm1hdHJpeCksIFxcc2FtcGxlSWRcXF1cbiAgICAgICAgcGFuZWxpZHMgPC0gZGF0YS5jb3B5W20kbWF0Y2gubWF0cml4LFxccGFuZWxJZFxcXVxuICAgICAgICBpZHMgPC0gZGF0YS5mcmFtZShzYW1wbGVJZD1zYW1wbGVpZHMsIHBhbmVsSWQ9cGFuZWxpZHMsIHN0cmluZ3NBc0ZhY3RvcnMgPSBGKVxuICAgICAgICBkZiA8LSBtZXJnZSh4PWRmLCB5PWlkcywgYnk9XFxzYW1wbGVJZFxcLCBhbGwueCA9IFRSVUUsIHN1ZmZpeGVzPWMoXFxcXCxhcy5jaGFyYWN0ZXIoaSkpKVxuICAgICAgICB9IFxuICAgIClcbiAgICBkYXRhLmNvcHkgPC0gZGF0YS5jb3B5WyFkYXRhLmNvcHkkcGFuZWxJZCAlaW4lIGNvbnRyb2xzJHBhbmVsSWQsXSAjIG5vdCByZWx5aW5nIG9uIHJvd25hbWVzXG4gICAgXG4gIH1cbiAgcmV0dXJuKGxpc3QoXFxpZHNcXD1kZiwgXFxtYXRjaGVzXFw9bWF0Y2hlcykpXG59XG5cbmBgYFxuYGBgIn0= -->

```r
```r
matchRatio <- function(data, metric, n, exact = c()){
  # A wrapper for the MatchIt framework to carry out arbitrary numbers of successive matches
  # data must have:
  #   * sampleId
  #   * panelId
  #   * treat
  require(MatchIt)
    
  # assign the dataframe to hold the matching results
  df <- data.frame(matrix(ncol=1, nrow=sum(data$treat==1)))
  names(df) <- c(\sampleId\)
  df$sampleId <- data$sampleId[data$treat==1]
  
  # assign the object to hold all the matching information
  matches <- vector(\list\,n)
  
  # make a copy of the passed-in data
  data.copy <- data.frame(data)
  
  # loop over the number of respondents per target
  # if there are issues, can I relax the age groups?
  for(i in 1:n){
    print(paste('i = ',as.character(i)))
    m <- matchit(matching.form, 
                 data = data.copy, exact=exact, method = \nearest\, distance = metric)
    controls <- match.data(m, group='control')
    
    try({matches[[i]] <- m
        sampleids <- data.copy[row.names(m$match.matrix), \sampleId\]
        panelids <- data.copy[m$match.matrix,\panelId\]
        ids <- data.frame(sampleId=sampleids, panelId=panelids, stringsAsFactors = F)
        df <- merge(x=df, y=ids, by=\sampleId\, all.x = TRUE, suffixes=c(\\,as.character(i)))
        } 
    )
    data.copy <- data.copy[!data.copy$panelId %in% controls$panelId,] # not relying on rownames
    
  }
  return(list(\ids\=df, \matches\=matches))
}

```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->





<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxubiA8LSAxMFxubWF0Y2hlcyA9IG1hdGNoUmF0aW8oYWxsZGF0YSwgXFxtYWhhbGFub2Jpc1xcLCBuLCBleGFjdCA9IGMoXFxhZ2VfZ3JvdXBcXCxcXGdlbmRcXCkpXG5gYGBcbmBgYCJ9 -->

```r
```r
n <- 10
matches = matchRatio(alldata, \mahalanobis\, n, exact = c(\age_group\,\gend\))
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFxcaSA9ICAxXFxcblsxXSBcXGkgPSAgMlxcXG5bMV0gXFxpID0gIDNcXFxuWzFdIFxcaSA9ICA0XFxcblsxXSBcXGkgPSAgNVxcXG5bMV0gXFxpID0gIDZcXFxuWzFdIFxcaSA9ICA3XFxcblsxXSBcXGkgPSAgOFxcXG5bMV0gXFxpID0gIDlcXFxuWzFdIFxcaSA9ICAxMFxcXG4ifQ== -->

```
[1] \i =  1\
[1] \i =  2\
[1] \i =  3\
[1] \i =  4\
[1] \i =  5\
[1] \i =  6\
[1] \i =  7\
[1] \i =  8\
[1] \i =  9\
[1] \i =  10\
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


Save the id's of the matches to a file

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxud3JpdGUuY3N2KFxuICBtYXRjaGVzJGlkcywgXG4gIGZpbGU9cGFzdGUwKGRhdGFkaXIsXFxwYW5lbC9cXCxjb3VudHJ5LFxcX3NlbGVjdGVkX3dhdmVcXCx3YXZlLFxcX1xcLGZvcm1hdChTeXMudGltZSgpLFxcJXklbSVkXFwpLFxcLmNzdlxcKSxcbiAgcm93Lm5hbWVzID0gRilcbndhdmVcbmBgYFxuYGBgIn0= -->

```r
```r
write.csv(
  matches$ids, 
  file=paste0(datadir,\panel/\,country,\_selected_wave\,wave,\_\,format(Sys.time(),\%y%m%d\),\.csv\),
  row.names = F)
wave
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDNcbiJ9 -->

```
[1] 3
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->

Make sure I got the right sampleIds...

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuc3VtKG1hdGNoZXMkaWRzJHNhbXBsZUlkJWluJXByZXZpb3VzJHNhbXBsZUlkKT09bnJvdyhtYXRjaGVzJGlkcylcblxuYGBgXG5gYGAifQ== -->

```r
```r
sum(matches$ids$sampleId%in%previous$sampleId)==nrow(matches$ids)

```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIFRSVUVcbiJ9 -->

```
[1] TRUE
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->



Do I have a good number of discrete location codes?

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxubGVuZ3RoKHVuaXF1ZShwYW5lbCRYKSlcbmBgYFxuYGBgIn0= -->

```r
```r
length(unique(panel$X))
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDMzNVxuIn0= -->

```
[1] 335
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxubGVuZ3RoKHVuaXF1ZSh0YXJnZXQkWCkpXG5gYGBcbmBgYCJ9 -->

```r
```r
length(unique(target$X))
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiWzFdIDE5OFxuIn0= -->

```
[1] 198
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuc29ydCh0YWJsZSh0YXJnZXQkWCkpXG5gYGBcbmBgYCJ9 -->

```r
```r
sort(table(target$X))
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG4gICAgICAgIC03MS40NjA3NSAgICAgICAgIC03MC45NzkxNiAgICAgICAgIC03MC4xMjc3OCAgICAgICAgIC02OS4zMDA2MSAgICAgICAgICAtNjkuMDkwMSBcbiAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxIFxuICAgICAgICAtNjguNTIxOTMgICAgICAgICAtNjguNDY3MDggICAgICAgICAtNjguMzA1NzUgICAgICAgICAtNjguMDMwODMgICAgICAgICAtNjcuOTIzMzYgXG4gICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSBcbiAgICAgICAgLTY3LjkwMjA1ICAgICAgICAgIC02Ny42NDI5ICAgICAgICAgIC02Ni44OTc1ICAgICAgICAgLTY2LjUxMzU4ICAgICAgICAgLTY2LjMzMTE2IFxuICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgXG4gICAgICAgIC02Ni4zMjk5MSAgICAgICAgIC02NS44MDUwNiAgICAgICAgIC02NS43Nzk1MyAgICAgICAgICAtNjUuNjMyNCAgICAgICAgIC02NS40NzA2MiBcbiAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxIFxuICAgICAgICAtNjUuNDQ1ODMgICAgICAgICAtNjUuMjkwMzQgICAgICAgICAtNjUuMjU2MjIgICAgICAgICAtNjUuMjAyOTkgICAgICAgICAtNjUuMTI0MjcgXG4gICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSBcbiAgICAgICAgLTY1LjA2OTg2ICAgICAgICAgLTY0Ljk3ODk5ICAgICAgICAgLTY0Ljk1ODMzICAgICAgICAgLTY0Ljc5MjI5ICAgICAgICAgLTY0Ljc1NjUzIFxuICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgXG4gICAgICAgIC02NC41OTg5NyAgICAgICAgIC02NC41NTY5MSAgICAgICAgIC02NC40MzkzMyAgICAgICAgIC02NC4zNjgwNCAgICAgICAgIC02My45MzEwNiBcbiAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxIFxuICAgICAgICAtNjMuNzc5MjUgICAgICAgICAtNjMuNzMyODcgICAgICAgICAtNjMuNjI1ODkgICAgICAgICAtNjMuMjA1MzggICAgICAgICAtNjIuODI3OTYgXG4gICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSBcbiAgICAgICAgLTYyLjYzNDY3ICAgICAgICAgLTYxLjg4ODk1ICAgICAgICAgLTYxLjgzNDM1ICAgICAgICAgLTYxLjgyMTM3ICAgICAgICAgLTYxLjgwODk2IFxuICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgXG4gICAgICAgIC02MS41MzI0MyAgICAgICAgIC02MS41MTExNyAgICAgICAgIC02MS4zOTc5OCAgICAgICAgIC02MS4zMzI3NSAgICAgICAgIC02MS4yNzQwMyBcbiAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxIFxuICAgICAgICAtNjEuMDA1OTggICAgICAgICAtNjAuOTc1MDIgICAgICAgICAtNjAuODgzNzEgICAgICAgICAtNjAuNjcwMDQgICAgICAgICAtNjAuNDg5OTEgXG4gICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSBcbiAgICAgICAgLTYwLjQ2MjI3ICAgICAgICAgLTYwLjIxOTM2ICAgICAgICAgLTYwLjEyNjg4ICAgICAgICAgLTYwLjA2MjkyICAgICAgICAgLTYwLjAxNTA0IFxuICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgXG4gICAgICAgIC01OS45NTg3OSAgICAgICAgIC01OS45MjU1MSAgICAgICAgIC01OS43MDM0OCAgICAgICAgIC01OS42NDg3NyAgICAgICAgIC01OS42MDIyNyBcbiAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxIFxuICAgICAgICAgLTU5LjQ5MzIgICAgICAgICAgLTU5LjQ3MjQgICAgICAgICAtNTkuNDA5NDcgICAgICAgICAtNTkuMTgyMzQgICAgICAgICAtNTkuMTU2ODEgXG4gICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSBcbiAgICAgICAgLTU5LjEwMTU5ICAgICAgICAgLTU4LjkzMzc0ICAgICAgICAgLTU4Ljg4Mjk0ICAgICAgICAgLTU4Ljg0NzEzICAgICAgICAgLTU4LjgyOTk4IFxuICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgXG4gICAgICAgIC01OC41NDQ3OCAgICAgICAgIC01OC40ODg5NiAgICAgICAgIC01OC40MzEyNyAgICAgICAgIC01OC4zOTc2OSAgICAgICAgIC01OC4yNTU0MiBcbiAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAxIFxuICAgICAgICAtNTguMTU4NDEgICAgICAgICAgLTU3Ljk4MDcgICAgICAgICAtNTcuNjM1NzcgICAgICAgICAtNTYuOTM1MjggICAgICAgICAtNTYuOTI1ODEgXG4gICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSAgICAgICAgICAgICAgICAgMSBcbiAgICAgICAgLTU2Ljg3MzI0ICAgICAgICAgLTU0LjYzMzE1ICAgICAgICAgLTU0LjQyMzMyICAgICAgICAgLTU0LjM5NTkxICAgICAgICAgLTU0LjI2OTA1IFxuICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgICAgICAgICAgICAgICAgIDEgXG4gICAgICAgIC01My45NjM2MyAgICAgICAgIC02OC45MDExOSAgICAgICAgIC02OC43NDE3NyAgICAgICAgICAgLTY4LjYwOCAgICAgICAgIC02OC40MDkyOCBcbiAgICAgICAgICAgICAgICAxICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyIFxuICAgICAgICAtNjguMjkzMTYgICAgICAgICAtNjguMjM0NDEgICAgICAgICAtNjcuNzA5MzggICAgICAgICAgIC02Ni45MTQgICAgICAgICAtNjYuMzcwMjcgXG4gICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiBcbiAgICAgICAgIC02NS43MTM5ICAgICAgICAgLTY1LjcwMjY2ICAgICAgICAgLTY1LjA4NjMyICAgICAgICAgICAtNjQuODIyICAgICAgICAgLTY0LjE4MDcxIFxuICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDIgXG4gICAgICAgIC02My42NjIwNSAgICAgICAgIC02My42NjEyNCAgICAgICAgIC02My40Mzg1NiAgICAgICAgIC02My4yNTYyMiAgICAgICAgIC02Mi44NDcxMiBcbiAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyIFxuICAgICAgICAtNjIuMzA0MTIgICAgICAgICAtNjIuMjc3MTIgICAgICAgICAtNjIuMTY5ODggICAgICAgICAtNjEuNjU3NzggICAgICAgICAtNjEuMTEwMDQgXG4gICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiBcbiAgICAgICAgIC02MC41MzI4ICAgICAgICAgLTYwLjQyNDMzICAgICAgICAgLTYwLjQxMzkyICAgICAgICAgLTU5LjUyNzk2ICAgICAgICAgLTU5LjEyNzUzIFxuICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDIgXG4gICAgICAgIC01OC45MTcxNyAgICAgICAgIC01OC44NjU0NiAgICAgICAgIC01OC42ODgxNiAgICAgICAgIC01OC42NDkwNyAgICAgICAgIC01OC40MzE2NCBcbiAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyICAgICAgICAgICAgICAgICAyIFxuICAgICAgICAtNTguMzc4MTYgICAgICAgICAtNTguMzcwMDcgICAgICAgICAtNTguMjM3MzggICAgICAgICAgLTU3Ljg2OTMgICAgICAgICAtNTcuMjIzMDEgXG4gICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiAgICAgICAgICAgICAgICAgMiBcbiAgICAgICAgLTU1LjU4MzQ2ICAgICAgICAgLTcwLjU2NjM5ICAgICAgICAgLTY4LjkwMTIxICAgICAgICAgIC02OC41MzQyICAgICAgICAgLTY1LjM0NTQzIFxuICAgICAgICAgICAgICAgIDIgICAgICAgICAgICAgICAgIDMgICAgICAgICAgICAgICAgIDMgICAgICAgICAgICAgICAgIDMgICAgICAgICAgICAgICAgIDMgXG4gICAgICAgIC02NC45MjMwNSAgICAgICAgIC02NC42MjE0MyAgICAgICAgIC02NC40MzIyNCAgICAgICAgIC02NC4zMDcwNiAgICAgICAgIC02NC4xNTI4NiBcbiAgICAgICAgICAgICAgICAzICAgICAgICAgICAgICAgICAzICAgICAgICAgICAgICAgICAzICAgICAgICAgICAgICAgICAzICAgICAgICAgICAgICAgICAzIFxuICAgICAgICAtNjAuOTYzMjUgICAgICAgICAtNjAuODUyODUgICAgICAgICAtNjAuNTQ0NDQgICAgICAgICAtNjAuNTI1NDUgICAgICAgICAtNTkuNDIwOTYgXG4gICAgICAgICAgICAgICAgMyAgICAgICAgICAgICAgICAgMyAgICAgICAgICAgICAgICAgMyAgICAgICAgICAgICAgICAgMyAgICAgICAgICAgICAgICAgMyBcbiAgICAgICAgLTU5LjE2NjI2ICAgICAgICAgLTU4Ljk4NjA5ICAgICAgICAgLTU4Ljc3NzA1ICAgICAgICAgLTU4Ljc2NDAyICAgICAgICAgLTU4LjU2NDE1IFxuICAgICAgICAgICAgICAgIDMgICAgICAgICAgICAgICAgIDMgICAgICAgICAgICAgICAgIDMgICAgICAgICAgICAgICAgIDMgICAgICAgICAgICAgICAgIDMgXG4gICAgICAgIC01OC41MDUzNCAgICAgICAgIC01OC40NzYyNyAgICAgICAgIC01OC4xNTUyMiAgICAgICAgIC01Ny44MjcyNCAgICAgICAgIC01NS44NTgwNiBcbiAgICAgICAgICAgICAgICAzICAgICAgICAgICAgICAgICAzICAgICAgICAgICAgICAgICAzICAgICAgICAgICAgICAgICAzICAgICAgICAgICAgICAgICAzIFxuICAgICAgICAtNTQuODAxNzQgICAgICAgICAtNzEuNTMwMTUgICAgICAgICAtNjkuMjcyNjUgICAgICAgICAtNjguNjY4OTggICAgICAgICAtNjguMzUwNTYgXG4gICAgICAgICAgICAgICAgMyAgICAgICAgICAgICAgICAgNCAgICAgICAgICAgICAgICAgNCAgICAgICAgICAgICAgICAgNCAgICAgICAgICAgICAgICAgNCBcbiAgICAgICAgLTY1Ljg0MjAxICAgICAgICAgLTY1LjI0OTA4ICAgICAgICAgLTY0LjU4NjE1ICAgICAgICAgLTYyLjUyNTE1ICAgICAgICAgIC02MC4yOTI1IFxuICAgICAgICAgICAgICAgIDQgICAgICAgICAgICAgICAgIDQgICAgICAgICAgICAgICAgIDQgICAgICAgICAgICAgICAgIDQgICAgICAgICAgICAgICAgIDQgXG4gICAgICAgIC02MC4wNDM4NCAgICAgICAgIC01OC45MDI1NiAgICAgICAgIC01OC43NDEyNSAgICAgICAgIC01OC41NjM3MyAgICAgICAgIC01OC41Mzc5NCBcbiAgICAgICAgICAgICAgICA0ICAgICAgICAgICAgICAgICA0ICAgICAgICAgICAgICAgICA0ICAgICAgICAgICAgICAgICA0ICAgICAgICAgICAgICAgICA0IFxuICAgICAgICAtNTguMzQxMzYgICAgICAgICAtNjcuNTU4MDcgICAgICAgICAtNjUuMjE3ODUgICAgICAgICAtNjQuNDkzMzQgICAgICAgICAtNTguNzExNDMgXG4gICAgICAgICAgICAgICAgNCAgICAgICAgICAgICAgICAgNSAgICAgICAgICAgICAgICAgNSAgICAgICAgICAgICAgICAgNSAgICAgICAgICAgICAgICAgNSBcbiAgICAgICAgLTU4LjM5NDEyICAgICAgICAgLTY1LjQzMjYxICAgICAgICAgLTY1LjI3MTE4ICAgICAgICAgLTYxLjk0NjQ2ICAgICAgICAgLTU4LjYwNjQ0IFxuICAgICAgICAgICAgICAgIDUgICAgICAgICAgICAgICAgIDYgICAgICAgICAgICAgICAgIDYgICAgICAgICAgICAgICAgIDYgICAgICAgICAgICAgICAgIDYgXG4gICAgICAgICAtNTguMDE4MSAgICAgICAgIC01OC42OTE0MyAgICAgICAgIC01OC4yNTgwNiAgICAgICAgIC01OC42MTkyOSAgICAgICAgIC01OC41Nzg4MyBcbiAgICAgICAgICAgICAgICA2ICAgICAgICAgICAgICAgICA3ICAgICAgICAgICAgICAgICA3ICAgICAgICAgICAgICAgICA4ICAgICAgICAgICAgICAgICA4IFxuICAgICAgICAtNTkuMTE0NTUgICAgICAgICAtNTguODEwMzYgICAgICAgICAtNTguMzY2ODggICAgICAgICAtNjguODAwODUgICAgICAgICAtNTcuNzQwMDYgXG4gICAgICAgICAgICAgICAgOSAgICAgICAgICAgICAgICAgOSAgICAgICAgICAgICAgICAgOSAgICAgICAgICAgICAgICAxMCAgICAgICAgICAgICAgICAxMCBcbiAgICAgICAgLTU4LjQyMzQ3ICAgICAgICAgLTYwLjY2OTYyICAgICAgICAgLTU4LjI3Njc4IC01OC40NDg4ODA0MTAxMjUxICAgICAgICAgLTYwLjcwNjY4IFxuICAgICAgICAgICAgICAgMTEgICAgICAgICAgICAgICAgMTMgICAgICAgICAgICAgICAgMTMgICAgICAgICAgICAgICAgMTQgICAgICAgICAgICAgICAgMTYgXG4gICAgICAgIC02NC4xODMyMiAgICAgICAgIC01OC42MjQ2MSAgICAgICAgIC01OC40NDg4OCBcbiAgICAgICAgICAgICAgIDIzICAgICAgICAgICAgICAgIDM0ICAgICAgICAgICAgICAgIDM4IFxuIn0= -->

```

        -71.46075         -70.97916         -70.12778         -69.30061          -69.0901 
                1                 1                 1                 1                 1 
        -68.52193         -68.46708         -68.30575         -68.03083         -67.92336 
                1                 1                 1                 1                 1 
        -67.90205          -67.6429          -66.8975         -66.51358         -66.33116 
                1                 1                 1                 1                 1 
        -66.32991         -65.80506         -65.77953          -65.6324         -65.47062 
                1                 1                 1                 1                 1 
        -65.44583         -65.29034         -65.25622         -65.20299         -65.12427 
                1                 1                 1                 1                 1 
        -65.06986         -64.97899         -64.95833         -64.79229         -64.75653 
                1                 1                 1                 1                 1 
        -64.59897         -64.55691         -64.43933         -64.36804         -63.93106 
                1                 1                 1                 1                 1 
        -63.77925         -63.73287         -63.62589         -63.20538         -62.82796 
                1                 1                 1                 1                 1 
        -62.63467         -61.88895         -61.83435         -61.82137         -61.80896 
                1                 1                 1                 1                 1 
        -61.53243         -61.51117         -61.39798         -61.33275         -61.27403 
                1                 1                 1                 1                 1 
        -61.00598         -60.97502         -60.88371         -60.67004         -60.48991 
                1                 1                 1                 1                 1 
        -60.46227         -60.21936         -60.12688         -60.06292         -60.01504 
                1                 1                 1                 1                 1 
        -59.95879         -59.92551         -59.70348         -59.64877         -59.60227 
                1                 1                 1                 1                 1 
         -59.4932          -59.4724         -59.40947         -59.18234         -59.15681 
                1                 1                 1                 1                 1 
        -59.10159         -58.93374         -58.88294         -58.84713         -58.82998 
                1                 1                 1                 1                 1 
        -58.54478         -58.48896         -58.43127         -58.39769         -58.25542 
                1                 1                 1                 1                 1 
        -58.15841          -57.9807         -57.63577         -56.93528         -56.92581 
                1                 1                 1                 1                 1 
        -56.87324         -54.63315         -54.42332         -54.39591         -54.26905 
                1                 1                 1                 1                 1 
        -53.96363         -68.90119         -68.74177           -68.608         -68.40928 
                1                 2                 2                 2                 2 
        -68.29316         -68.23441         -67.70938           -66.914         -66.37027 
                2                 2                 2                 2                 2 
         -65.7139         -65.70266         -65.08632           -64.822         -64.18071 
                2                 2                 2                 2                 2 
        -63.66205         -63.66124         -63.43856         -63.25622         -62.84712 
                2                 2                 2                 2                 2 
        -62.30412         -62.27712         -62.16988         -61.65778         -61.11004 
                2                 2                 2                 2                 2 
         -60.5328         -60.42433         -60.41392         -59.52796         -59.12753 
                2                 2                 2                 2                 2 
        -58.91717         -58.86546         -58.68816         -58.64907         -58.43164 
                2                 2                 2                 2                 2 
        -58.37816         -58.37007         -58.23738          -57.8693         -57.22301 
                2                 2                 2                 2                 2 
        -55.58346         -70.56639         -68.90121          -68.5342         -65.34543 
                2                 3                 3                 3                 3 
        -64.92305         -64.62143         -64.43224         -64.30706         -64.15286 
                3                 3                 3                 3                 3 
        -60.96325         -60.85285         -60.54444         -60.52545         -59.42096 
                3                 3                 3                 3                 3 
        -59.16626         -58.98609         -58.77705         -58.76402         -58.56415 
                3                 3                 3                 3                 3 
        -58.50534         -58.47627         -58.15522         -57.82724         -55.85806 
                3                 3                 3                 3                 3 
        -54.80174         -71.53015         -69.27265         -68.66898         -68.35056 
                3                 4                 4                 4                 4 
        -65.84201         -65.24908         -64.58615         -62.52515          -60.2925 
                4                 4                 4                 4                 4 
        -60.04384         -58.90256         -58.74125         -58.56373         -58.53794 
                4                 4                 4                 4                 4 
        -58.34136         -67.55807         -65.21785         -64.49334         -58.71143 
                4                 5                 5                 5                 5 
        -58.39412         -65.43261         -65.27118         -61.94646         -58.60644 
                5                 6                 6                 6                 6 
         -58.0181         -58.69143         -58.25806         -58.61929         -58.57883 
                6                 7                 7                 8                 8 
        -59.11455         -58.81036         -58.36688         -68.80085         -57.74006 
                9                 9                 9                10                10 
        -58.42347         -60.66962         -58.27678 -58.4488804101251         -60.70668 
               11                13                13                14                16 
        -64.18322         -58.62461         -58.44888 
               23                34                38 
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


What are these NAs? --oh, it was the censusId! fixed now.

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxubGFwcGx5KG5hbWVzKGFsbGRhdGEpLCBmdW5jdGlvbih4KXtcbiAgcHJpbnQoeClcbiAgYWxsZGF0YVtpcy5uYShhbGxkYXRhW1t4XV0pLF1cbiAgfSlcbmBgYFxuYGBgIn0= -->

```r
```r
lapply(names(alldata), function(x){
  print(x)
  alldata[is.na(alldata[[x]]),]
  })
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->

What does the sample look like?

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxudGFibGUodGFyZ2V0LnBydW5lZCRlZCkvbnJvdyh0YXJnZXQucHJ1bmVkKVxuXG5gYGBcbmBgYCJ9 -->

```r
```r
table(target.pruned$ed)/nrow(target.pruned)

```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG4gICAgICAgICAyICAgICAgICAgIDMgICAgICAgICAgNCAgICAgICAgICA1IFxuMC40OTY2NDQzMCAwLjQyOTUzMDIwIDAuMDQ2OTc5ODcgMC4wMjY4NDU2NCBcbiJ9 -->

```

         2          3          4          5 
0.49664430 0.42953020 0.04697987 0.02684564 
```



<!-- rnb-output-end -->

<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxudGFibGUoc2V0JGVkKS9ucm93KHNldClcbmBgYFxuYGBgIn0= -->

```r
```r
table(set$ed)/nrow(set)
```
```

<!-- rnb-source-end -->

<!-- rnb-output-begin eyJkYXRhIjoiXG4gICAgICAgICAgMSAgICAgICAgICAgMiAgICAgICAgICAgMyAgICAgICAgICAgNCAgICAgICAgICAgNSBcbjAuMDA0MDI2ODQ2IDAuNDIwODA1MzY5IDAuNDg5MjYxNzQ1IDAuMDYxNzQ0OTY2IDAuMDI0MTYxMDc0IFxuIn0= -->

```

          1           2           3           4           5 
0.004026846 0.420805369 0.489261745 0.061744966 0.024161074 
```



<!-- rnb-output-end -->

<!-- rnb-chunk-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxudGFyZ2V0LnBydW5lZFssY2Vuc3VzSWQ6PXN1YnN0cihzYW1wbGVJZCwxLDEyKV1cbnRhcmdldC5wcnVuZWRbLFBFUk5VTTo9c3Vic3RyKGNlbnN1c0lkLDExLDEyKV1cbnRhcmdldC5wcnVuZWRbLFNFUklBTDo9c3Vic3RyKGNlbnN1c0lkLDEsMTApXVxud3JpdGUuY3N2KHRhcmdldC5wcnVuZWQscGFzdGUwKFxccHJ1bmVkX3RhcmdldF9cXCxmb3JtYXQoU3lzLnRpbWUoKSxcXCV5JW0lZFxcKSxcXC5jc3ZcXCkpXG53cml0ZS5jc3Yoc2V0LHBhc3RlMChcXHNlbGVjdGVkX0lEc19cXCxmb3JtYXQoU3lzLnRpbWUoKSxcXCV5JW0lZFxcKSxcXC5jc3ZcXCkpXG5gYGBcbmBgYCJ9 -->

```r
```r
target.pruned[,censusId:=substr(sampleId,1,12)]
target.pruned[,PERNUM:=substr(censusId,11,12)]
target.pruned[,SERIAL:=substr(censusId,1,10)]
write.csv(target.pruned,paste0(\pruned_target_\,format(Sys.time(),\%y%m%d\),\.csv\))
write.csv(set,paste0(\selected_IDs_\,format(Sys.time(),\%y%m%d\),\.csv\))
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->


What does it look like, compared to the old sample?

<!-- rnb-text-end -->


<!-- rnb-chunk-begin -->


<!-- rnb-source-begin eyJkYXRhIjoiYGBgclxuYGBgclxuc2FtcGxlLm9sZCA8LSBmcmVhZChcXEM6L1VzZXJzL3NjaGFkZW0vQm94IFN5bmMvTEFQT1AgU2hhcmVkL3dvcmtpbmcgZG9jdW1lbnRzL21haXRhL0Nvb3JkaW5hdGlvbi9Ob2FtIEFyZ2VudGluYSBQYW5lbC9NYXRjaGluZyBwcm9jZXNzL0RhdGEvQVIvc2FtcGxlL0FSX3RhcmdldF8yMDE5MDkwOS5jc3ZcXClcbmhpc3Qoc2FtcGxlLm9sZCRhZ2UpXG5oaXN0KHRhcmdldCRhZ2UpXG5gYGBcbmBgYCJ9 -->

```r
```r
sample.old <- fread(\C:/Users/schadem/Box Sync/LAPOP Shared/working documents/maita/Coordination/Noam Argentina Panel/Matching process/Data/AR/sample/AR_target_20190909.csv\)
hist(sample.old$age)
hist(target$age)
```
```

<!-- rnb-source-end -->

<!-- rnb-chunk-end -->


<!-- rnb-text-begin -->






<!-- rnb-text-end -->

