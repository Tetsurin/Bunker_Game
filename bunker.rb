require 'json'

class BunkerPlayers
    @@chosen_professions = []
    @@chosen_hobby = []
    @@chosen_phobia = []
    @@chosen_character_trait = []
    @@chosen_baggage = []
    @@chosen_additional_information = []
    @@chosen_genders = []
    @@chosen_orientation = []
    @@player_count = 0
    @@catastrophe = nil
    @@bunker_characteristics = nil

    def initialize
        load_characteristics
        generate_catastrophe_and_bunker_characteristics
        @@player_count += 1
        @player_number = @@player_count
        @profession = select_unique_characteristic(@professions_list, @@chosen_professions)
        @hobby = select_unique_characteristic(@hobby_list, @@chosen_hobby)
        @health = select_health
        @phobia = select_phobia
        @character_trait = select_unique_characteristic(@character_traits_list, @@chosen_character_trait)
        @baggage = select_unique_characteristic(@baggage_list, @@chosen_baggage)
        @additional_information = select_unique_characteristic(@additional_information_list, @@chosen_additional_information)
        @gender = select_gender
        @age = select_age
        @orientation = select_orientation


        @player_folder = File.expand_path('players', __dir__)
        Dir.mkdir(@player_folder) unless File.exist?(@player_folder)

        @file_name = "player_#{@player_number}.txt"
        save_characteristics_to_file

    end

    def save_characteristics_to_file
        file_path = File.join("players", @file_name)
    
        File.open(file_path, "w") do |file|
        file.puts("Катастрофа:\n#{@@catastrophe}")
        file.puts("\nХарактеристики бункера:\n#{@@bunker_characteristics}")
        file.puts("\nГравець #{@player_number}:")
        file.puts("Професія та стать: #{@profession}, #{@gender}")
        file.puts("Вік та сексуальна орієнтація: #{@age}, #{@orientation}")
        file.puts("Стан здоров'я: #{@health}")
        file.puts("Фобія: #{@phobia}")
        file.puts("Хобі: #{@hobby}")
        file.puts("Риса характеру: #{@character_trait}")
        file.puts("Багаж: #{@baggage}")
        file.puts("Додаткова інформація: #{@additional_information}")
        end
    end

    def  load_characteristics
        begin
            json_file = File.read('characteristics.json')
            data = JSON.parse(json_file)
            @professions_list = data["profession"]
            @hobby_list = data["hobby"]
            @light_dis_list = data["light_dis"]
            @mid_dis_list = data["mid_dis"]
            @hard_dis_list = data["hard_dis"]
            @phobia_list = data["phobia"]
            @character_traits_list = data["character_trait"]
            @baggage_list = data["baggage"]
            @additional_information_list = data["additional_information"]
            @catastrophe_list = data["catastrophe"]
            @bunker_characteristics_list = data["bunker_characteristics"] 
            
        rescue Errno::ENOENT
            puts "Помилка: файл characteristics.json не знайдено."
        rescue JSON::ParserError
            puts "Помилка: неможливо розпарсити JSON файл."
        end
        
    end

    def select_unique_characteristic(characteristics_list, chosen_characteristics)
        loop do
            characteristic_candidate = characteristics_list.sample
            unless chosen_characteristics.include?(characteristic_candidate)
                chosen_characteristics << characteristic_candidate
                return characteristic_candidate
            end
        end
    end

   def probability_configuration(characteristic_probabilities)
        total_probability = characteristic_probabilities.values.sum
        random_number = rand(1..total_probability)

        characteristic_group = nil
        cumulative_probability = 0

        characteristic_probabilities.each do |group, probability|
            cumulative_probability += probability
            if random_number <= cumulative_probability
                characteristic_group = group
                break
            end
        end 
        return characteristic_group
    end     

    def select_health
        health_probabilities = {
            "Ідеально здоровий" => 15,
            "Легка хвороба" => 45,
            "Хвороба середньої тяжкості" => 30,
            "Тяжка невиліковна хвороба" => 10
        }

        health_group = probability_configuration(health_probabilities)

        case health_group
        when "Ідеально здоровий"
            return "Ідеально здоровий"
        when "Легка хвороба"
            return @light_dis_list.sample
        when "Хвороба середньої тяжкості"
            return @mid_dis_list.sample
        when "Тяжка невиліковна хвороба"
            return @hard_dis_list.sample
        end
    end

    def select_phobia
        probability = rand(10)
        if probability < 8
            select_unique_characteristic(@phobia_list, @@chosen_phobia)
        else
            return "Не має фобій"
        end

    end

    def select_gender
        if @@chosen_genders.count("Чоловік") < @@chosen_genders.count("Жінка")
            return "Чоловік"
        elsif @@chosen_genders.count("Чоловік") > @@chosen_genders.count("Жінка")
            return "Жінка"
        else
            return rand(2) == 0 ? "Чоловік" : "Жінка"
        end
    end

    def select_age
        age_probabilities = {
            "18-29" => 60,
            "30-49" => 35,
            "50-80" => 5
        }

        age_group = probability_configuration(age_probabilities)

        case age_group
        when "18-29"
            return rand(18..29)
        when "30-49"
            return rand(30..49)
        when "50-80"
            return rand(50..80)
        end
    end

   def select_orientation
        traditional_probability = 70

        if rand(1..100) <= traditional_probability
            return "Традиційна орієнтація"
        else
            return "Не традиційна орієнтація"
        end
    end

    def generate_catastrophe_and_bunker_characteristics
        if @@catastrophe.nil? || @@bunker_characteristics.nil?
            @@catastrophe = @catastrophe_list.sample
            @@bunker_characteristics = @bunker_characteristics_list.sample
        end
    end

    def show_characteristics
        puts "Катастрофа:\n#{@@catastrophe}"
        puts "\nХарактеристики бункера:\n#{@@bunker_characteristics}"
        puts "\nГравець #{@player_number}:"
        puts "Професія та стать: #{@profession}, #{@gender}"
        puts "Вік та сексуальна орієнтація: #{@age}, #{@orientation}"
        puts "Стан здоров'я: #{@health}"
        puts "Фобія: #{@phobia}"
        puts "Хобі: #{@hobby}"
        puts "Риса характеру: #{@character_trait}"
        puts "Багаж: #{@baggage}"
        puts "Додаткова інформація: #{@additional_information}"
        puts "\n"
    end

end

def create_bunker_players(number_of_players)
    players = []
    for i in 1..number_of_players
        players << BunkerPlayers.new
    end
    return players
end

print "Введіть кількість гравців: "
number_of_players = gets.chomp

players = create_bunker_players(number_of_players.to_i)
players.each {|player| player.show_characteristics}

