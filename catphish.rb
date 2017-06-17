#!/usr/bin/env ruby

# catphish - Domain Suggester
# version: 0.0.5
# author: Viet Luu
# author: Kent 'picat' Gruber
# web: www.ring0lab.com


# Next update
# more algorithms

require 'set'
require 'trollop'
require 'resolv'
require 'simpleidn'
require 'whois'
require 'whois-parser'

module Catphish

  VERSION = '0.0.5'

  POPULAR_TOP_DOMAINS = ['.com', '.co', '.net', '.org', '.info']

  COUNTRY_TOP_DOMAINS = [
    ".ac", ".ad", ".ae", ".af", ".ag", ".ai", ".al", ".am", ".an", ".ao", ".aq", ".ar", ".as",
    ".at", ".au", ".aw", ".ax", ".az", ".ba", ".bb", ".bd", ".be", ".bf", ".bg", ".bh", ".bi",
    ".bj", ".bm", ".bn", ".bo", ".bq", ".br", ".bs", ".bt", ".bv", ".bw", ".by", ".bz", ".ca", 
    ".cc", ".cd", ".cf", ".cg", ".ch", ".ci", ".ck", ".cl", ".cm", ".cn", ".co", ".cr", ".cu", 
    ".cv", ".cw", ".cx", ".cy", ".cz", ".de", ".dj", ".dk", ".dm", ".do", ".dz", ".ec", ".ee",
    ".eg", ".eh", ".er", ".es", ".et", ".eu", ".fi", ".fj", ".fk", ".fm", ".fo", ".fr", ".ga", 
    ".gb", ".gd", ".ge", ".gf", ".gg", ".gh", ".gi", ".gl", ".gm", ".gn", ".gp", ".gq", ".gr", 
    ".gs", ".gt", ".gu", ".gw", ".gy", ".hk", ".hm", ".hn", ".hr", ".ht", ".hu", ".id", ".ie", 
    ".il", ".im", ".in", ".io", ".iq", ".ir", ".is", ".it", ".je", ".jm", ".jo", ".jp", ".ke", 
    ".kg", ".kh", ".ki", ".km", ".kn", ".kp", ".kr", ".kw", ".ky", ".kz", ".la", ".lb", ".lc", 
    ".li", ".lk", ".lr", ".ls", ".lt", ".lu", ".lv", ".ly", ".ma", ".mc", ".md", ".me", ".mg",
    ".mh", ".mk", ".ml", ".mm", ".mn", ".mo", ".mp", ".mq", ".mr", ".ms", ".mt", ".mu", ".mv", 
    ".mw", ".mx", ".my", ".mz", ".na", ".nc", ".ne", ".nf", ".ng", ".ni", ".nl", ".no", ".np", 
    ".nr", ".nu", ".nz", ".om", ".pa", ".pe", ".pf", ".pg", ".ph", ".pk", ".pl", ".pm", ".pn", 
    ".pr", ".ps", ".pt", ".pw", ".py", ".qa", ".re", ".ro", ".rs", ".ru", ".rw", ".sa", ".sb", 
    ".sc", ".sd", ".se", ".sg", ".sh", ".si", ".sj", ".sk", ".sl", ".sm", ".sn", ".so", ".sr", 
    ".ss", ".st", ".su", ".sv", ".sx", ".sy", ".sz", ".tc", ".td", ".tf", ".tg", ".th", ".tj", 
    ".tk", ".tl", ".tm", ".tn", ".to", ".tp", ".tr", ".tt", ".tv", ".tw", ".tz", ".ua", ".ug",
    ".uk", ".us", ".uy", ".uz", ".va", ".vc", ".ve", ".vg", ".vi", ".vn", ".vu", ".wf", ".ws", 
    ".ye", ".yt", ".za", ".zm", ".zw" ]

  GENERIC_DOMAINS = [
    ".academy", ".accountant", ".accountants", ".active", ".actor", ".adult", ".aero", 
    ".agency", ".airforce", ".apartments", ".app", ".archi", ".army", ".associates", 
    ".attorney", ".auction", ".audio", ".autos", ".band", ".bar", ".bargains", ".beer", 
    ".best", ".bid", ".bike", ".bingo", ".bio", ".biz", ".black", ".blackfriday", ".blog", 
    ".blue", ".boo", ".boutique", ".build", ".builders", ".business", ".buzz", ".cab", ".cam", 
    ".camera", ".camp", ".cancerresearch", ".capital", ".cards", ".care", ".career", ".careers", 
    ".cars", ".cash", ".casino", ".catering", ".center", ".ceo", ".channel", ".chat", ".cheap", 
    ".christmas", ".church", ".city", ".claims", ".cleaning", ".click", ".clinic", ".clothing", 
    ".cloud", ".club", ".coach", ".codes", ".coffee", ".college", ".community", ".company", 
    ".computer", ".condos", ".construction", ".consulting", ".contractors", ".cooking", ".cool", 
    ".coop", ".country", ".coupons", ".credit", ".creditcard", ".cricket", ".cruises", ".dad", 
    ".dance", ".date", ".dating", ".day", ".deals", ".degree", ".delivery", ".democrat", ".dental", 
    ".dentist", ".design", ".diamonds", ".diet", ".digital", ".direct", ".directory", ".discount", 
    ".dog", ".domains", ".download", ".eat", ".education", ".email", ".energy", ".engineer", 
    ".engineering", ".equipment", ".esq", ".estate", ".events", ".exchange", ".expert", ".exposed", 
    ".express", ".fail", ".faith", ".family", ".fans", ".farm", ".fashion", ".feedback", ".finance", 
    ".financial", ".fish", ".fishing", ".fit", ".fitness", ".flights", ".florist", ".flowers", ".fly", 
    ".foo", ".football", ".forsale", ".foundation", ".fund", ".furniture", ".fyi", ".gallery", ".garden", 
    ".gift", ".gifts", ".gives", ".glass", ".global", ".gold", ".golf", ".gop", ".graphics", ".green", 
    ".gripe", ".guide", ".guitars", ".guru", ".healthcare", ".help", ".here", ".hiphop", ".hiv", ".hockey", 
    ".holdings", ".holiday", ".homes", ".horse", ".host", ".hosting", ".house", ".how", ".info", ".ing", 
    ".ink", ".institute", ".insure", ".international", ".investments", ".jewelry", ".jobs", ".kim", ".kitchen", 
    ".land", ".lawyer", ".lease", ".legal", ".lgbt", ".life", ".lighting", ".limited", ".limo", ".link", 
    ".loan", ".loans", ".lol", ".lotto", ".love", ".luxe", ".luxury", ".management", ".market", ".marketing", 
    ".markets", ".mba", ".media", ".meet", ".meme", ".memorial", ".men", ".menu", ".mobi", ".moe", ".money", 
    ".mortgage", ".motorcycles", ".mov", ".movie", ".museum", ".name", ".navy", ".network", ".new", ".news", 
    ".ngo", ".ninja", ".one", ".ong", ".onl", ".online", ".ooo", ".organic", ".partners", ".parts", ".party", 
    ".pharmacy", ".photo", ".photography", ".photos", ".physio", ".pics", ".pictures", ".pid", ".pink", ".pizza", 
    ".place", ".plumbing", ".plus", ".poker", ".porn", ".post", ".press", ".pro", ".productions", ".prof", 
    ".properties", ".property", ".qpon", ".racing", ".recipes", ".red", ".rehab", ".ren", ".rent", ".rentals", 
    ".repair", ".report", ".republican", ".rest", ".review", ".reviews", ".rich", ".rip", ".rocks", ".rodeo", 
    ".rsvp", ".run", ".sale", ".school", ".science", ".services", ".sex", ".sexy", ".shoes", ".show", ".singles", 
    ".site", ".soccer", ".social", ".software", ".solar", ".solutions", ".space", ".studio", ".style", ".sucks", 
    ".supplies", ".supply", ".support", ".surf", ".surgery", ".systems", ".tattoo", ".tax", ".taxi", ".team", 
    ".store", ".tech", ".technology", ".tel", ".tennis", ".theater", ".tips", ".tires", ".today", ".tools", ".top", 
    ".tours", ".town", ".toys", ".trade", ".training", ".travel", ".university", ".vacations", ".vet", ".video", 
    ".villas", ".vision", ".vodka", ".vote", ".voting", ".voyage", ".wang", ".watch", ".webcam", ".website", ".wed", 
    ".wedding", ".whoswho", ".wiki", ".win", ".wine", ".work", ".works", ".world", ".wtf", ".xxx", ".xyz", ".yoga", ".zone"]

  CHARS_MAP = {
    "a" => ["\u1EA1", "\u0101", "\u0203", "\u00E0", "\u00E1"], 
    "e" => ["\u1EB9", "\u0113", "\u0207", "\u00E8", "\u00E9"], 
    "c" => ["\u0107"],
    "d" => ["\u0111", "\u010F"], 
    "i" => ["\u1EC9", "\u1ECB", "\u012B", "\u00EC", "\u020B"],
    "o" => ["\u1ECD", "\u014D", "\u020F", "\u00F2", "\u00F3"], 
    "u" => ["\u1EE5", "\u016B", "\u0217", "\u00F9", "\u00FA"], 
    "r" => ["\u0155", "\u0213"],
    "t" => ["\u0165"],
    "y" => ["\u1EF7", "\u00FD"],
    "z" => ["\u017E"]
  }	

  # Current langs: Vietnamese, Croation and Czech
  CYRILLIC_CHARS_MAP = {
    "a" => "\u0430", "b" => "\u0432", "c" => "\u0441", "e" => "\u0435",
    "f" => "\u0493", "h" => "\u04BB", "i" => "\u0456", "k" => "\u043A",
    "l" => "\u04CF", "m" => "\u043C", "n" => "\u04E5", "o" => "\u043E",
    "p" => "\u0440", "r" => "\u0433", "s" => "\u0455", "t" => "\u0442",
    "u" => "\u0446", "w" => "\u0428", "x" => "\u0445", "y" => "\u0423"
  }

  HOMOGLYPH_SUBSTITUTE_CHARACTERS = {
    "0" => "o", "1" => "l", "o" => "0", "m" => "rm", "d" => "cl",
    "g" => "q", "i" => "l", "l" => "i", "p" => "q", "cl" => "d",
    "q" => "g", "u" => "v", "v" => "u", "w" => "vv", "y" => "v"
  }

  #METHODS = ['SingularOrPluralise', 'prependOrAppend', 'homoglyphs', 'doubleExtensions', 'mirrorization', 'dashOmission']

  #:def self.analyze_domain(domain)
  #:  domain = domain.split('.')[0]
  #:  domain_container = []
  #:end

  def self.methods
    return METHODS unless block_given?
    METHODS.each { |method| yield method }
  end

  def self.mirrorization(domain)
    domain = domain.split('.')[0]
    domain_container = Set.new
    domain_container << (['Standard', domain])
    (0...domain.size).each do |i|
      d = domain.clone
      if (i == domain.size - 2 || d[i+1] == '-')
        d[i+1] = d[i] + d[i+1]
      elsif (d[i] == '-')
        d[i] = d[i]
      elsif (d[i] == d[i+1] || d[i] == d[i-1])
        # do nothing
      else
        d[i+1] = d[i]
      end	
      domain_container << ['Mirrorization',d]
    end
    domain_container
  end

  def self.singular_or_pluralise(domain)
    domain = domain.split('.')[0]
    domain_container = Set.new
    domain_container << ['Standard', domain]
    d = domain.clone
    if (d[domain.size - 1] == 's')
      d = d.chomp(d[domain.size - 1])
      domain_container << ['SingularOrPluralise',d]
    else
      d[domain.size] = "s"
      domain_container << ['SingularOrPluralise',d]
    end
  end

  def self.prepend_or_append(domain) 
    domain = domain.split('.')[0]
    domain_container = Set.new
    domain_container << ['Standard', domain]
    words = ['www-', '-www', 'http-', '-https']
    words.each do |w|
      d = domain.clone
      if (w[0] == '-')
        d = d + w
      else
        d = w + d
      end
      domain_container << ['PrependOrAppend',d]
    end
    domain_container
  end

  def self.homoglyphs(domain)
    domain = domain.split('.')[0]
    domain_container = Set.new
    domain_container << ['Standard', domain]
    HOMOGLYPH_SUBSTITUTE_CHARACTERS.each do |k, v|
      (0...domain.size).each do |i|
        d, d2 = domain.clone, domain.clone
        if (d[i] == k)
          d[i] = v
          domain_container << ['Homoglyphs',d]
          domain_container << ['Homoglyphs',d2 = d2.gsub(k, v)]
        end
      end
      d = domain.clone
      if (d.include?("cl"))
        d = d.sub('cl', 'd')
        domain_container << ['Homoglyphs',d]
      end
    end
    domain_container
  end


  def self.double_extensions(domain)
    domain = domain.split('.')[0]
    domain_container = Set.new
    domain_container << ['Standard', domain]
    return [] if domain.split('.')[1].nil?
    domain_container << ['Double Extensions', domain.split('.')[0] + '-' +  domain.split('.')[1]]
    domain_container
  end

  def self.dash_omission(domain)
    domain = domain.split('.')[0]
    domain_container = Set.new
    domain_container << ['Standard', domain]
    d = domain.clone
    if (d.include?('-'))
      d = d.gsub('-', '')
      domain_container << ['Dash Omission',d]
    end
    domain_container
  end

  def self.punycode(domain)
    domain = domain.split('.')[0]
    domain_container = Set.new

    @D2 = domain.clone

    CHARS_MAP.each do |k, v|
      d = domain.clone
      (0...domain.size).each do |i|
        if (d[i] == k)
          (0...v.size).each do |i2|
            d[i] = v[i2]
            @D2[i] = v[i2]
            domain_container << ['Punycode',d, SimpleIDN.to_ascii(d)]
            d = domain.clone
          end
        end
      end

      container = domain_container.dup
      container.each do |domain|
        temp_domain = []
        (0...v.size).each do |i3|
          temp_domain << (domain[1].gsub!(k, v[i3]))
          if !temp_domain[0].nil?
            domain_container << ['Punycode',temp_domain[0], SimpleIDN.to_ascii(temp_domain[0])]
          end
        end
      end	
    end

    domain_container << ['Punycode',@D2, SimpleIDN.to_ascii(@D2)]

    d = domain.clone
    punyValid = true
    if domain =~ /d|g|q|v|z/
      punyValid = false
    end
    CYRILLIC_CHARS_MAP.each do |k, v|
      (0...domain.size).each do |i|
        if (d[i] == k)
          d[i] = v
        end
      end
    end
    if punyValid
      domain_container << ['Punycode',d, SimpleIDN.to_ascii(d)]
    end
    domain_container
  end

  def self.start(domain_container, domain_types: POPULAR_TOP_DOMAINS, all: false, punycode: false, header: false)
    threads = []
    if punycode
      printf "%-30s %-30s %-30s %s\n\n", "Type", "Domain", "Punycode", "Status" if header
      extension = ".com"
      domain_container.each do |d|
        threads << Thread.new do
          if (Whois.whois("#{d[2] + extension}").parser.available?)
            printf "%-30s %-30s %-30s %s\n", d[0], d[1] + extension, d[2].to_s + extension, "\e[32mAvailable\e[0m"
          else
            if all
              printf "%-30s %-30s %-30s %s\n", d[0], d[1] + extension, d[2].to_s + extension, "Not Available"
            end
          end
        end
      end
      thread.each {|t| t.join}
    else
      printf "%-30s %-30s %s\n\n", "Type", "Domain", "Status" if header
      domain_types.each do |extension|
        domain_container.each do |d|
          threads << Thread.new do
            begin
              if !(Resolv.getaddress "#{d[1] + extension}").nil?
                if all
                  printf "%-30s %-30s %s\n", d[0], d[1] + extension, "Not Available"
                end
              end
            rescue Exception
              printf "%-30s %-30s %s\n", d[0], d[1] + extension, "\e[32mAvailable\e[0m"
            end
          end
        end
        threads.each {|t| t.join}
      end
    end

  end

  def self.logo
    "
 ██████╗ █████╗ ████████╗██████╗ ██╗  ██╗██╗███████╗██╗  ██╗
██╔════╝██╔══██╗╚══██╔══╝██╔══██╗██║  ██║██║██╔════╝██║  ██║
██║     ███████║   ██║   ██████╔╝███████║██║███████╗███████║
██║     ██╔══██║   ██║   ██╔═══╝ ██╔══██║██║╚════██║██╔══██║
╚██████╗██║  ██║   ██║   ██║     ██║  ██║██║███████║██║  ██║
 ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝╚══════╝╚═╝  ╚═╝
                                                    [v]#{VERSION} 
                                               Author: Mr. V & Picat 
                                           Web: ring0lab.com                                                                       
    "
  end


end

ARGV[0] = '-h' if ARGV.empty?

opts = Trollop::options do
  banner Catphish.logo
  opt :logo,                  "ASCII art banner",                                   type: :bool,    default: true
  opt :column_header,         "Header for each column of the output",               type: :bool,    default: true
  opt :Domain,                "Target domain to analyze",                           type: :string, required: (ARGV[0] == '-h' ? false : true)
  opt :type,                  "Type of level domains: (popular, country, generic)", type: :string,  default: 'popular'
  opt :Verbose,               "Show all domains, including non-available ones",     type: :bool,    default: false
  opt :All,                   "Use all of the possible methods",                    type: :bool,    default: false
  opt :Mirrorization,         "Use the mirrorization method.",                      type: :bool,    default: false
  opt :singular_or_pluralise, "Use the singular or pluralise method.",              type: :bool,    default: false
  opt :prepend_or_append,     "Use the prepend or append method.",                  type: :bool,    default: false
  opt :Homoglyphs,            "Use the homoglyphs method.",                         type: :bool,    default: false
  opt :double_extensions,     "Use the double extensions method",                   type: :bool,    default: false
  opt :Dash_omission,         "Use the dash omission method.",                      type: :bool,    default: false
  opt :Punycode,              "Use the punycode method.",                           type: :bool,    default: false
end

domains = Set.new
if opts[:All]
  [:Mirrorization, :singular_or_pluralise, :prepend_or_append, :Homoglyphs, :double_extensions, :dash_omission, :Punycode].each do |opt|
    Catphish.send(opt.to_s.downcase.to_sym, opts[:Domain]).each do |domain|
      domains << domain
    end
  end
else
  [:Mirrorization, :singular_or_pluralise, :prepend_or_append, :Homoglyphs, :double_extensions, :dash_omission, :Punycode].each do |opt|
    next unless opts[opt]
    Catphish.send(opt.to_s.downcase.to_sym, opts[:Domain]).each do |domain|
      domains << domain
    end
  end
end

case opts[:type].downcase.to_sym
when :country
  type = Catphish::COUNTRY_TOP_DOMAINS
when :generic 
  type = Catphish::GENERIC_DOMAINS
else
  type = Catphish::POPULAR_TOP_DOMAINS
end

if opts[:Punycode]
  puny = true
else
  puny = false
end

puts Catphish.logo if opts[:logo]

Catphish.start(domains, domain_types: type, all: opts[:Verbose], punycode: puny, header: opts[:column_header])
