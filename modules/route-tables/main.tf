resource "aws_route_table" "rt" {
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = var.route_table_name
    }
  )
}

resource "aws_route" "route" {
  count                  = length(var.routes)
  route_table_id         = aws_route_table.rt.id
  destination_cidr_block = var.routes[count.index].destination_cidr_block
  gateway_id             = lookup(var.routes[count.index], "gateway_id", null)
  nat_gateway_id         = lookup(var.routes[count.index], "nat_gateway_id", null)
}

resource "aws_route_table_association" "rta" {
  count          = length(var.subnet_ids)
  subnet_id      = var.subnet_ids[count.index]
  route_table_id = aws_route_table.rt.id
}
