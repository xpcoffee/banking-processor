require_relative '../lib/banking_processor/processors/output_processor'

output = BankingProcessor::Processor::OutputProcessor.new
processor.export_balance_data
processor.export_breakdown_data