

import Foundation
class SearchResponse : Codable {
	let resultCount : Int?
	let results : [Results]?

	enum CodingKeys: String, CodingKey {

		case resultCount = "resultCount"
		case results = "results"
	}

    required init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)
		resultCount = try values.decodeIfPresent(Int.self, forKey: .resultCount)
		results = try values.decodeIfPresent([Results].self, forKey: .results)
	}

}
