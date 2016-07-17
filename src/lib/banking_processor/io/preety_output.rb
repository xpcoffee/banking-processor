module BankingProcessor
  module IO
   class PreetyOutput
    def heading(message)
      border = '=' * message.length

      puts border
      puts message
      puts border
    end

    def end_section
      puts '-' * 40
      puts ''
    end
   end
 end
end