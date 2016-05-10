require_relative '../lib/processors/output_processor'

processor = OutputProcessor.new
processor.export_balance_data
processor.export_breakdown_data