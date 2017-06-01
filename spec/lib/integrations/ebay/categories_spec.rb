require "rails_helper"

describe Integrations::Ebay::Categories do
  before do
    @integration = Integrations::Ebay::Instance
    @integration_obj = Integrations::Ebay::Instance.new({})
  end

  let(:raw_data_category_fields_15032) { open([File.dirname(__FILE__), 'category_fields_response_15032.xml'].join('/')).read.gsub("\n", '') }
  let(:raw_data_category_fields_176976) { open([File.dirname(__FILE__), 'category_fields_response_176976.xml'].join('/')).read.gsub("\n", '') }

  it 'should return no category fields for category id 15032' do
    stub_request(:post, 'https://api.ebay.com/ws/api.dll').to_return(status: 200, body: raw_data_category_fields_15032, headers: {})
    expect(@integration_obj.category_fields(15032)).to eq([])
  end

  it 'should return correct category fields for category id 176976' do
    stub_request(:post, 'https://api.ebay.com/ws/api.dll').to_return(status: 200, body: raw_data_category_fields_176976, headers: {})

    resp = [
        {
            name: 'spec_brand',
            required: false,
            data_type: :string,
            data_options: ['Unbranded/Generic', 'Amazon', 'Apple', 'Belkin', 'BlackBerry', 'Dell', 'Griffin Technology', 'HP', 'IOGEAR', 'Kensington', 'Kingston', 'Motorola', 'PNY', 'Samsung', 'SanDisk', 'SGP', 'Sony', 'Targus', 'TEAC', 'Toshiba']
        },
        {
            name: 'spec_type',
            required: false,
            data_type: :string,
            data_options: ['Card Reader', 'Card Reader & USB Host', 'USB Host Adapter']
        },
        {
            name: 'spec_compatible_brand',
            required: false,
            data_type: :string,
            data_options: ["Universal", "For Acer", "For Amazon", "For Apple", "For Archos", "For ASUS", "For Barnes & Noble", "For BlackBerry", "For Coby", "For Creative", "For Dell", "For Fujitsu", "For HP", "For HTC", "For Microsoft", "For Motion Computing", "For Motorola", "For Notion Ink", "For Panasonic", "For Pandigital", "For Samsung", "For Sony", "For Toshiba", "For Velocity Micro", "For ViewSonic"]
        },
        {
            name: 'spec_compatible_product_line',
            required: false,
            data_type: :string,
            data_options: ["Universal", "Archos 101", "Archos 28", "Archos 32", "Archos 43", "Archos 48", "Archos 5", "Archos 7", "Archos 70 eReader", "Archos 70 Tablet", "Archos 8", "Cius", "Cruz Reader", "Cruz Tablet", "Eee Pad Slider", "Eee Pad Transformer", "Flyer", "Folio 100", "Galaxy Note", "Galaxy Tab", "Galaxy Tab 2", "Galaxy Tab 3", "Galaxy Tab 4", "gTablet", "Iconia Tab A100"]
        },
        {
            name: 'spec_memory_cards_supported',
            required: false,
            data_type: :string,
            data_options: ["Not Applicable", "CompactFlash I", "CompactFlash II", "Memory Stick", "Memory Stick Duo", "Memory Stick Micro (M2)", "Memory Stick PRO", "Memory Stick PRO Duo", "Memory Stick PRO-HG Duo", "microSD", "microSDHC", "MiniSD", "MiniSDHC", "MMC", "MMCmicro", "MMCmobile", "MMCplus", "P2", "RS-MMC", "SD", "SDHC", "SDXC", "SmartMedia", "SxS", "xD-Picture Card"]
        },
        {
            name: 'spec_model',
            required: false,
            data_type: :string,
            data_options: []
        },
        {
            name: 'spec_mpn',
            required: false,
            data_type: :string,
            data_options: ['Does Not Apply']
        },
        {
            name: 'spec_country_region_of_manufacture',
            required: false,
            data_type: :enum,
            data_options: ["Unknown", "Afghanistan", "Albania", "Algeria", "American Samoa", "Andorra", "Angola", "Anguilla", "Antarctica", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bermuda", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Bouvet Island", "Brazil", "British Indian Ocean Territory", "Brunei Darussalam", "Bulgaria", "Burkina Faso", "Burundi", "Cambodia", "Cameroon", "Canada", "Cape Verde", "Cayman Islands", "Central African Republic", "Chad", "Chile", "China", "Christmas Island", "Cocos (Keeling) Islands", "Colombia", "Comoros", "Congo", "Congo, The Democratic Republic of the", "Cook Islands", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cyprus", "Czech Republic", "Denmark", "Djibouti", "Dominica", "Dominican Republic", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Falkland Islands (Malvinas)", "Faroe Islands", "Fiji", "Finland", "France", "French Guiana", "French Polynesia Includes Tahiti", "French Southern Territories", "Gabon", "Gambia", "Georgia", "Germany", "Ghana", "Gibraltar", "Greece", "Greenland", "Grenada", "Guadeloupe", "Guam", "Guatemala", "Guernsey", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Heard Island and Mcdonald Islands", "Holy See (Vatican City State)", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jersey", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, Republic of", "Kuwait", "Kyrgyzstan", "Lao People's Democratic Republic", "Latvia", "Lebanon", "Lesotho", "Liberia", "Libyan Arab Jamahiriya", "Liechtenstein", "Lithuania", "Luxembourg", "Macao", "Macedonia, the Former Yugoslav Republic of", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Martinique", "Mauritania", "Mauritius", "Mayotte", "Mexico", "Micronesia, Federated States of", "Moldova, Republic of", "Monaco", "Mongolia", "Montenegro", "Montserrat", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "Netherlands Antilles", "New Caledonia", "New Zealand", "Nicaragua", "Niger", "Nigeria", "Niue", "Norfolk Island", "Northern Mariana Islands", "Norway", "Oman", "Pakistan", "Palau", "Palestinian territory, Occupied", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Pitcairn", "Poland", "Portugal", "Puerto Rico", "Qatar", "Reunion", "Romania", "Russian Federation", "Rwanda", "Saint Helena", "Saint Kitts and Nevis", "Saint Lucia", "Saint Pierre and Miquelon", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Georgia and the South Sandwich Islands", "Spain", "Sri Lanka", "Suriname", "Svalbard and Jan Mayen", "Swaziland", "Sweden", "Switzerland", "Taiwan", "Tajikistan", "Tanzania, United Republic of", "Thailand", "Togo", "Tokelau", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Turks and Caicos Islands", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "United States", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Virgin Islands, British", "Virgin Islands, U S", "Wallis and Futuna", "Western Sahara", "Yemen", "Zambia", "Zimbabwe"]
        },
    ]
    expect(@integration_obj.category_fields(176976)).to eq(resp)
  end

  let(:raw_data_categories) { open([File.dirname(__FILE__), 'categories_response.xml'].join('/')).read.gsub("\n", '') }

  it 'should return correct categories from mobile' do
    stub_request(:post, 'https://api.ebay.com/ws/api.dll').to_return(status: 200, body: raw_data_categories, headers: {})
    resp = [{name: 'Cell Phones & Smartphones', id: '9355', parent_id: '15032', has_children: false},
            {name: 'Smart Watches', id: '178893', parent_id: '15032', has_children: false},
            {name: 'Smart Watch Accessories', id: '182064', parent_id: '15032', has_children: true},
            {name: 'Cell Phone Accessories', id: '9394', parent_id: '15032', has_children: true},
            {name: 'Display Phones', id: '136699', parent_id: '15032', has_children: false},
            {name: 'Phone Cards & SIM Cards', id: '146492', parent_id: '15032', has_children: true},
            {name: 'Cell Phone & Smartphone Parts', id: '43304', parent_id: '15032', has_children: false},
            {name: 'Vintage Cell Phones', id: '182073', parent_id: '15032', has_children: false},
            {name: 'Wholesale Lots', id: '45065', parent_id: '15032', has_children: true},
            {name: 'Other Cell Phones & Accs', id: '42428', parent_id: '15032', has_children: false}]
    expect(@integration_obj.categories(15032)).to eq(resp)
  end

  it 'should return only categories from zero level' do
    stub_request(:post, 'https://api.ebay.com/ws/api.dll').to_return(status: 200, body: raw_data_categories, headers: {})
    resp = [{name: 'Antiques', id: '20081', parent_id: '20081', has_children: true},
            {name: 'Art', id: '550', parent_id: '550', has_children: true},
            {name: 'Baby', id: '2984', parent_id: '2984', has_children: true},
            {name: 'Books', id: '267', parent_id: '267', has_children: true},
            {name: 'Business & Industrial', id: '12576', parent_id: '12576', has_children: true},
            {name: 'Cameras & Photo', id: '625', parent_id: '625', has_children: true},
            {name: 'Cell Phones & Accessories', id: '15032', parent_id: '15032', has_children: true},
            {name: 'Clothing, Shoes & Accessories', id: '11450', parent_id: '11450', has_children: true},
            {name: 'Coins & Paper Money', id: '11116', parent_id: '11116', has_children: true},
            {name: 'Collectibles', id: '1', parent_id: '1', has_children: true},
            {name: 'Computers/Tablets & Networking', id: '58058', parent_id: '58058', has_children: true},
            {name: 'Consumer Electronics', id: '293', parent_id: '293', has_children: true},
            {name: 'Crafts', id: '14339', parent_id: '14339', has_children: true},
            {name: 'Dolls & Bears', id: '237', parent_id: '237', has_children: true},
            {name: 'DVDs & Movies', id: '11232', parent_id: '11232', has_children: true},
            {name: 'Entertainment Memorabilia', id: '45100', parent_id: '45100', has_children: true},
            {name: 'Gift Cards & Coupons', id: '172008', parent_id: '172008', has_children: true},
            {name: 'Health & Beauty', id: '26395', parent_id: '26395', has_children: true},
            {name: 'Home & Garden', id: '11700', parent_id: '11700', has_children: true},
            {name: 'Jewelry & Watches', id: '281', parent_id: '281', has_children: true},
            {name: 'Music', id: '11233', parent_id: '11233', has_children: true},
            {name: 'Musical Instruments & Gear', id: '619', parent_id: '619', has_children: true},
            {name: 'Pet Supplies', id: '1281', parent_id: '1281', has_children: true},
            {name: 'Pottery & Glass', id: '870', parent_id: '870', has_children: true},
            {name: 'Real Estate', id: '10542', parent_id: '10542', has_children: true},
            {name: 'Specialty Services', id: '316', parent_id: '316', has_children: true},
            {name: 'Sporting Goods', id: '888', parent_id: '888', has_children: true},
            {name: 'Sports Mem, Cards & Fan Shop', id: '64482', parent_id: '64482', has_children: true},
            {name: 'Stamps', id: '260', parent_id: '260', has_children: true},
            {name: 'Tickets & Experiences', id: '1305', parent_id: '1305', has_children: true},
            {name: 'Toys & Hobbies', id: '220', parent_id: '220', has_children: true},
            {name: 'Travel', id: '3252', parent_id: '3252', has_children: true},
            {name: 'Video Games & Consoles', id: '1249', parent_id: '1249', has_children: true},
            {name: 'Everything Else', id: '99', parent_id: '99', has_children: true}]
    expect(@integration_obj.categories).to eq(resp)
  end

end