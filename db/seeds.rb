# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
Skill.create!(
  [{ name: 'Knitting' }, { name: 'Crocheting' }, { name: 'Quilting' }, ]
)

Product.create!(
  [
    { name: 'Sweaters' },
    { name: 'Garments' },
    { name: 'Accessories', description: 'e.g. socks, mittens, gloves, scarves' },
    { name: 'Quilts' },
    { name: 'Blankets', description: 'Knit or crochet' },
    { name: 'Rugs' },
  ]
)