require 'rubygems'
require 'zip'

class FileHandler

    def output_file_contents(path)
        for_contents(path) { |line|
            puts line
        }
    end

    # Yield for each line in a file.
    # If the file is zipped, the block is passed to an equivalent
    # method for zipped files.
    def for_contents(path)
        if(path.end_with? 'zip')
            for_zipped_contents(path) { |line| yield(line) }
        else
            File.open(path, "r") do |file|
                file.each_line do |line|
                    yield(line)
                end
            end
        end
    end

    # Yield for each line in a zipped file.
    def for_zipped_contents(path)
        Zip::ZipFile.open(path) do |archive|
            archive.each do |entry|
                if entry.file?
                    entry.get_input_stream.each do |line|
                        yield(line)
                    end
                else
                    raise ArgumentError.new('No files contained within the compressed archive.')
                end
            end
        end
    end

    # Yield for every file in a directory
    def for_files(path)
        files_names = Dir[path]
        files_names.each do |filename|
            yield(filename)
        end
    end
end