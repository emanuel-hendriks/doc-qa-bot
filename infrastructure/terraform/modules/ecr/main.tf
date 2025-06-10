resource "aws_ecr_repository" "this" {
  for_each = toset(var.repositories)

  name = each.value

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = merge(
    var.tags,
    {
      Name = each.value
    }
  )
}

resource "aws_ecr_lifecycle_policy" "this" {
  for_each = toset(var.repositories)

  repository = aws_ecr_repository.this[each.key].name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"
        selection = {
          tagStatus     = "any"
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}
