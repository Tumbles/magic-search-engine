require "rake/testtask"
require "pathname"
require "fileutils"

def db
  @db ||= begin
    require_relative "lib/card_database"
    json_path = Pathname(__dir__) + "data/index.json"
    CardDatabase.load(json_path)
  end
end

task :default => :test

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.options = "-s0" # random order is just annoying
  t.verbose = true
end

desc "Generate index"
task "index" do
  system "./bin/indexer"
end

desc "Fetch new mtgjson database"
task "mtgjson:update" do
  system *%W[wget http://mtgjson.com/json/AllSets-x.json -O data/AllSets-x.json]
  Rake::Task["index"].invoke
end

desc "Fetch Gatherer pics"
task "pics:gatherer" do
  # Pathname("pics").mkpath
  db.printings.each do |c|
    if c.multiverseid
      path = Pathname("pics/#{c.set_code}/#{c.number}.png")
      mirror_path = Pathname("gatherer/#{c.multiverseid}.,png")
      path.parent.mkpath
      if path.exist?
        # OK
      elsif mirror_path.exist?
        FileUtils.cp mirror_path, path
      else
        url = "http://gatherer.wizards.com/Handlers/Image.ashx?multiverseid=#{c.multiverseid}&type=card"
        puts "Downloading #{c.name} #{c.set_code} #{c.multiverseid}"
        system "wget", "-nv", "-nc", url, "-O", path.to_s
      end
    end
  end
end

desc "Fetch HQ pics"
task "pics:hq" do
  source_base = Pathname("/Users/taw/Downloads/mtg_hq2/CCGHQ MTG Pics/Fulls/Base and Expansion Sets")

  db.sets.each do |set_code, set|
    source_dir = source_base + set.gatherer_code
    next unless source_dir.exist?
    nth_card = Hash.new(0)

    set.printings.sort_by{|c| [c.number.to_i, c.number] }.each do |card|
      nth_card[card.name] += 1
      target_path = Pathname("frontend/public/cards_hq/#{card.set_code}/#{card.number}.png")
      next if target_path.exist?

      clean_name = card.name.tr(":", "")
      candidate_names = [
        "#{clean_name}.jpg",
        "#{clean_name}.full.jpg",
        "#{clean_name}#{nth_card[card.name]}.jpg",
        "#{clean_name}#{nth_card[card.name]}.full.jpg",
      ]
      match = candidate_names.find{|bn| (source_dir + bn).exist?}

      if match
        # puts "Found #{card.set.gatherer_code} - #{card.name}"
      else
        has_lq = Pathname("frontend/public/cards/#{card.set_code}/#{card.number}.png").exist?
        if has_lq
          warn "LQ only: #{card.set.gatherer_code} - #{card.name}"
        else
          warn "No pic:  #{card.set.gatherer_code} - #{card.name}"
        end
      end
    end
  end
end

desc "Print statistics about card pictures"
task "pics:statistics" do
  total = Hash.new(0)
  db.printings.each do |card|
    path_lq = Pathname("frontend/public/cards/#{card.set_code}/#{card.number}.png")
    path_hq = Pathname("frontend/public/cards_hq/#{card.set_code}/#{card.number}.png")
    total["all"] += 1
    total["lq"]  += 1 if path_lq.exist?
    total["hq"]  += 1 if path_hq.exist?
  end
  puts "Cards: #{total["all"]}"
  puts "LQ: #{total["lq"]}"
  puts "HQ: #{total["hq"]}"
end

desc "Clanup Rails files"
task "clean" do
  [
    "frontend/log/development.log",
    "frontend/log/test.log",
    "frontend/tmp",
  ].each do |path|
    system "trash", path if Pathname(path).exist?
  end
  Dir["**/.DS_Store"].each do |ds_store|
    FileUtils.rm ds_store
  end
end
