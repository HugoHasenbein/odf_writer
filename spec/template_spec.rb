RSpec.describe "Templates Types" do

  before(:each) do

    @field_01 = Faker::Company.name
    @field_02 = Faker::Name.name

    document.add_field(:field_01, @field_01)
    document.add_field(:field_02, @field_02)

    document.generate("spec/result/specs.odt")

    @data = Inspector.new("spec/result/specs.odt")

  end

  context "template from file" do
    let(:document) { ODFWriter::Document.new("spec/specs.odt") }

    it "works" do

      expect(@data.text).not_to match(/\[FIELD_01\]/)
      expect(@data.text).not_to match(/\[FIELD_02\]/)

      expect(@data.text).to match @field_01
      expect(@data.text).to match @field_02

    end
  end

  context "template from a String" do
    let(:document) { ODFWriter::Document.new(io: ::File.open("spec/specs.odt").read) }

    it "works" do

      expect(@data.text).not_to match(/\[FIELD_01\]/)
      expect(@data.text).not_to match(/\[FIELD_02\]/)

      expect(@data.text).to match @field_01
      expect(@data.text).to match @field_02

    end
  end

end
