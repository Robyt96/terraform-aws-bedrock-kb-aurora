locals {
  kb_map = { for _, kb in var.kb_config : kb.kb_name => kb }
}
