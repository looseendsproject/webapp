# frozen_string_literal: true

namespace :finisher_import do
  desc "Import Finishers"
  task finishers: [:environment] do |_t|
    knitting = Skill.find_or_create_by(name: "Knit")
    quilting = Skill.find_or_create_by(name: "Quilting")
    crocheting = Skill.find_or_create_by(name: "Crochet")
    needlepoint = Skill.find_or_create_by(name: "Needlepoint")
    cross_stitch = Skill.find_or_create_by(name: "Cross-stitch")
    sewing = Skill.find_or_create_by(name: "Sewing")
    spinning = Skill.find_or_create_by(name: "Spinning")
    rugs = Skill.find_or_create_by(name: "Rugs")
    punch_needle = Skill.find_or_create_by(name: "Punch Needle")
    tunisian_crochet = Skill.find_or_create_by(name: "Tunisian Crochet")
    latch_hook = Skill.find_or_create_by(name: "Latch Hook")
    embroidery = Skill.find_or_create_by(name: "Embroidery")
    weaving = Skill.find_or_create_by(name: "Weaving")
    tatting = Skill.find_or_create_by(name: "Tatting")
    mending = Skill.find_or_create_by(name: "Mending")
    crewel = Skill.find_or_create_by(name: "Crewel")
    knit_mending = Skill.find_or_create_by(name: "Knit Mending")
    crochet_mending = Skill.find_or_create_by(name: "Crochet Mending")
    sewing_mending = Skill.find_or_create_by(name: "Sewing Mending")

    db_skills = {
      knit: knitting,
      quilt: quilting,
      crochet: crocheting,
      needle: needlepoint,
      cross: cross_stitch,
      sew: sewing,
      spinning: spinning,
      rug: rugs,
      punch: punch_needle,
      tunisian: tunisian_crochet,
      latch: latch_hook,
      embroidery: embroidery,
      weav: weaving,
      tatting: tatting,
      mending: mending,
      crewel: crewel,
      "knit mending": knit_mending,
      "crochet mending": crochet_mending,
      "sewing mending": sewing_mending
    }

    sweaters = Product.find_or_create_by(name: "Sweaters")
    garments = Product.find_or_create_by(name: "Other Garments")
    accessories = Product.find_or_create_by(name: "Accessories")
    quilts = Product.find_or_create_by(name: "Quilts")
    blankets = Product.find_or_create_by(name: "Blankets")
    rugs = Product.find_or_create_by(name: "Rugs")

    db_products = {
      sweater: sweaters,
      garment: garments,
      accessor: accessories,
      quilt: quilts,
      blanket: blankets,
      rug: rugs
    }

    account_key = Rails.application.credentials[:google_client_secret]
    session = GoogleDrive::Session.from_service_account_key(StringIO.new(
                                                              JSON.generate(account_key)
                                                            ))
    spreadsheet = session.spreadsheet_by_title("MegaSheet for Shobana Only")
    worksheet = spreadsheet.worksheets.first

    puts worksheet.title

    _, *worksheet_body = worksheet.rows

    worksheet_body.each do |row|
      # a, b,     c,          d,         e,        F,      G     H.     I,       J            K,             L,            M,      N,           O,      P,        Q,           R,        S,      T,         U,           V,             W,       X,            Y
      id, ts, email, first_name, last_name, pronouns, street, city, state, country, postal_code, _, phone_number, _, unavailable, skills, products, skill_level, dislikes, smoker, how_heard, description, dominant_hand, post_ok, social_media = row
      next unless id.length.positive?

      next if User.exists?(email: email.downcase)

      user = User.create({
                           email: email.downcase,
                           first_name: first_name,
                           last_name: last_name,
                           heard_about_us: how_heard,
                           password: SecureRandom.hex
                         })

      m, d, y = ts.split[0].split("/")
      joined_on = Date.new(y.to_i, m.to_i, d.to_i)

      processed_country = if country
                            if %w[usa
                                  us].include?(country.strip.downcase) || country.strip == "united states"
                              "US"
                            else
                              country.strip.upcase
                            end
                          else
                            ""
                          end

      finisher = Finisher.create({
                                   joined_on: joined_on,
                                   user_id: user.id,
                                   chosen_name: "#{first_name} #{last_name}",
                                   pronouns: pronouns,
                                   phone_number: phone_number,
                                   description: "#{description}\n\n#{skills}\n\n#{skill_level}\n\n#{products}",
                                   street: street,
                                   city: city ? city.strip : "",
                                   state: if state
                                            state.strip.length == 2 ? state.strip.upcase : state.strip
                                          else
                                            ""
                                          end,
                                   country: processed_country,
                                   postal_code: postal_code ? postal_code.strip : "",
                                   dominant_hand: dominant_hand,
                                   dislikes: dislikes,
                                   no_smoke: smoker == "No",
                                   can_publicize: post_ok.length.positive?,
                                   social_media: social_media,
                                   terms_of_use: true,
                                   unavailable: unavailable.strip.length.positive?
                                 })

      if products.length.positive?
        db_products.each do |product_symbol, db_product|
          finisher.products << db_product if products.downcase.include?(product_symbol.to_s)
        end
      end

      rating = if skill_level.downcase.include?("beginner")
                 1
               elsif skill_level.downcase.include?("intermediate")
                 2
               else
                 skill_level.downcase.include?("pro") ? 3 : 2
               end

      if skills.length.positive?

        db_skills.each do |skill_symbol, db_skill|
          if skills.downcase.include?(skill_symbol.to_s)
            finisher.assessments << Assessment.new(skill_id: db_skill.id, rating: rating)
          end
        end
      end

      puts id
    end
  end
end
