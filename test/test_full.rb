require_relative "test_helper"

class CardDatabaseFullTest < Minitest::Test
  def setup
    @db = load_database
  end

  def test_stats
    assert_equal 15629, @db.cards.size
    assert_equal 29389, @db.printings.size
  end

  def test_formats
    assert_search_equal "f:standard", "legal:standard"
    assert_search_results "f:extended" # Does not exist according to mtgjson
    assert_search_equal "f:standard", "e:ori or e:ktk or e:frf or e:dtk or e:bfz"
    assert_search_equal 'f:"ravnica block"', "e:rav or e:gp or e:di"
    assert_search_equal 'f:"ravnica block"', 'legal:"ravnica block"'
    assert_search_equal 'f:"ravnica block"', 'b:ravnica'
    assert_search_differ 'f:"mirrodin block" t:land', 'b:"mirrodin" t:land'
  end

  def test_block_codes
    assert_search_equal "b:rtr", 'b:"Return to Ravnica"'
    assert_search_equal "b:in", 'b:Invasion'
    assert_search_equal "b:som", 'b:"Scars of Mirrodin"'
    assert_search_equal "b:som", 'b:scars'
    assert_search_equal "b:mi", 'b:Mirrodin'
  end

  def test_block_special_characters
    assert_search_equal %Q[b:us], "b:urza"
    assert_search_equal %Q[b:"Urza's"], "b:urza"
  end

  def test_block_contents
    assert_search_equal "e:rtr OR e:gtc OR e:dgm", "b:rtr"
    assert_search_equal "e:in or e:ps or e:ap", 'b:Invasion'
    assert_search_equal "e:isd or e:dka or e:avr", "b:Innistrad"
    assert_search_equal "e:lw or e:mt or e:shm or e:eve", "b:lorwyn"
    assert_search_equal "e:som or e:mbs or e:nph", "b:som"
    assert_search_equal "e:mi or e:ds or e:5dn", "b:mi"
    assert_search_equal "e:som", 'e:scars'
    assert_search_equal 'f:"lorwyn-shadowmoor block"', "b:lorwyn"
  end

  def test_edition_special_characters
    assert_search_equal "e:us", %Q[e:"Urza's Saga"]
    assert_search_equal "e:us", %Q[e:"Urza’s Saga"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza's"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza’s"]
    assert_search_equal "e:us or e:ul or e:ud", %Q[e:"urza"]
  end

  def test_part
    assert_search_results "part:cmc=1 part:cmc=2", "Death", "Life", "Tear", "Wear", "What", "When", "Where", "Who", "Why"
    assert_search_results "part:cmc=0 part:cmc=3 part:c:b", "Chosen of Markov", "Liliana, Defiant Necromancer", "Liliana, Heretical Healer", "Markov's Servant", "Screeching Bat", "Stalking Vampire"
  end

  def test_color_identity
    assert_search_results "ci:wu t:basic", "Island", "Plains", "Snow-Covered Island", "Snow-Covered Plains"
  end

  def test_year
    assert_search_results_printings "year=2013 t:jace",
      ["Jace, Memory Adept", "m14", "mbp"],
      ["Jace, the Mind Sculptor", "v13"]
  end

  def test_printed
    assert_search_equal "t:planeswalker printed=m12", "t:planeswalker e:m12"
    assert_search_results "t:jace printed=2013", "Jace, Memory Adept", "Jace, the Mind Sculptor"
    assert_search_results "t:jace printed=2012", "Jace, Architect of Thought", "Jace, Memory Adept"
    assert_search_results "t:jace firstprinted=2012", "Jace, Architect of Thought"

    # This is fairly silly, as it includes prerelease promos etc.
    assert_search_results "e:ktk firstprinted<ktk",
      "Abzan Ascendancy", "Act of Treason", "Anafenza, the Foremost",
      "Ankle Shanker", "Arc Lightning", "Avalanche Tusker", "Bloodsoaked Champion",
      "Bloodstained Mire", "Butcher of the Horde", "Cancel", "Crackling Doom",
      "Crater's Claws", "Crippling Chill", "Deflecting Palm", "Despise",
      "Dig Through Time", "Dragon Throne of Tarkir", "Dragon-Style Twins", "Duneblast",
      "Erase", "Flooded Strand", "Flying Crane Technique", "Forest", "Grim Haruspex",
      "Hardened Scales", "Herald of Anafenza", "High Sentinels of Arashin", "Icy Blast", "Incremental Growth", "Island", "Ivorytusk Fortress", "Jeering Instigator",
      "Jeskai Ascendancy", "Jeskai Elder", "Kheru Lich Lord", "Mardu Ascendancy",
      "Mardu Heart-Piercer", "Master of Pearls", "Mountain", "Mystic Monastery",
      "Narset, Enlightened Master", "Naturalize", "Necropolis Fiend", "Nomad Outpost",
      "Plains", "Polluted Delta", "Rakshasa Vizier", "Rattleclaw Mystic",
      "Sage of the Inward Eye", "Seek the Horizon", "Shatter", "Sidisi, Brood Tyrant",
      "Siege Rhino", "Smite the Monstrous", "Sultai Ascendancy", "Surrak Dragonclaw",
      "Swamp", "Temur Ascendancy", "Thousand Winds", "Trail of Mystery", "Trap Essence",
      "Trumpet Blast", "Utter End", "Villainous Wealth", "Windstorm", "Windswept Heath",
      "Wooded Foothills", "Zurgo Helmsmasher"

    assert_search_results "e:ktk lastprinted>ktk",
      "Act of Treason", "Ainok Tracker", "Altar of the Brood", "Arc Lightning", "Bloodfell Caves", "Bloodstained Mire", "Blossoming Sands", "Briber's Purse", "Debilitating Injury", "Disdainful Stroke", "Dismal Backwater", "Dragonscale Boon", "Dutiful Return", "Flooded Strand", "Forest", "Ghostfire Blade", "Grim Haruspex", "Heir of the Wilds", "Hordeling Outburst", "Island", "Jeering Instigator", "Jungle Hollow", "Mountain", "Mystic of the Hidden Way", "Naturalize", "Plains", "Polluted Delta", "Rugged Highlands", "Ruthless Ripper", "Scoured Barrens", "Shatter", "Smite the Monstrous", "Sultai Charm", "Summit Prowler", "Suspension Field", "Swamp", "Swiftwater Cliffs", "Thornwood Falls", "Tormenting Voice", "Tranquil Cove", "Utter End", "Watcher of the Roost", "Weave Fate", "Wind-Scarred Crag", "Windstorm", "Windswept Heath", "Wooded Foothills"
  end

  def test_firstprinted
    assert_search_results "t:planeswalker firstprinted=m12", "Chandra, the Firebrand", "Garruk, Primal Hunter", "Jace, Memory Adept"
  end

  def test_lastprinted
    assert_search_results "t:planeswalker lastprinted<=roe", "Chandra Ablaze", "Sarkhan the Mad"
    assert_search_results "t:planeswalker lastprinted<=2011",
      "Ajani Goldmane", "Ajani Vengeant", "Chandra Ablaze", "Elspeth Tirel",
      "Garruk Relentless", "Garruk, the Veil-Cursed", "Gideon Jura", "Liliana of the Veil",
      "Nissa Revane", "Sarkhan the Mad", "Sorin Markov", "Tezzeret, Agent of Bolas"
  end

  def test_time_travel_basic
    assert_search_equal "time:lw t:planeswalker", "e:lw t:planeswalker"
    assert_search_results "time:wwk t:jace", "Jace Beleren", "Jace, the Mind Sculptor"
  end

  def test_sort
    assert_search_results "t:chandra sort:name",
      "Chandra Ablaze", "Chandra Nalaar", "Chandra, Pyromaster", "Chandra, Roaring Flame", "Chandra, the Firebrand"
    assert_search_results "t:chandra sort:new",
      "Chandra, Roaring Flame", "Chandra, Pyromaster", "Chandra, the Firebrand", "Chandra Nalaar", "Chandra Ablaze"
    # Jace v Chandra printing of Chandra Nalaar changes order
    assert_search_results "t:chandra sort:newall",
      "Chandra, Roaring Flame", "Chandra Nalaar", "Chandra, Pyromaster", "Chandra, the Firebrand", "Chandra Ablaze"
    assert_search_results "t:chandra sort:old",
      "Chandra Nalaar", "Chandra Ablaze", "Chandra, the Firebrand", "Chandra, Pyromaster", "Chandra, Roaring Flame"
    assert_search_results "t:chandra sort:oldall",
      "Chandra Nalaar", "Chandra Ablaze", "Chandra, the Firebrand", "Chandra, Pyromaster", "Chandra, Roaring Flame"
  end
end
