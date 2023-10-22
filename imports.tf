resource "aws_key_pair" "hashi-najihun" {
    key_name = "hashi-najihun"
}

import {
  to = aws_key_pair.hashi-najihun
  id = "key-00f55d421b89b948c"
}