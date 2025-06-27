output "knownledge_base_ids" {
  value = {
    for _, kb in aws_bedrockagent_knowledge_base.kb : kb.name => kb.id
  }
  description = "Map of knowledge base names to their IDs"
}
