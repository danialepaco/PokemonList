//
//  ContentView.swift
//  Pokedex
//
//  Created by daniel parra on 15/04/20.
//  Copyright © 2020 daniel parra. All rights reserved.
//

import SwiftUI
import Alamofire
import KingfisherSwiftUI

struct ContentView: View {
    
    @ObservedObject var list = PokemonList()
    
    init() {
        getPokemon() 
    }
    
    func delete(at offsets: IndexSet) {
        list.pokemon.remove(atOffsets: offsets)
    }
    
    func getPokemon() {
        AF.request("https://pokeapi.co/api/v2/pokemon", method: .get).responseJSON { response in
            do {
                let decoder = JSONDecoder()
                guard let data = response.data else { return }
                var response = try decoder.decode(PokemonResponse.self, from: data)
                for (index, _) in response.pokemon.enumerated() {
                    response.pokemon[index].url = "\(index + 1)"
                    response.pokemon[index].name = response.pokemon[index].name.capitalized
                }
                self.list.pokemon = response.pokemon
            } catch {
                print(error)
            }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(list.pokemon, id: \.name) { poke in
                    NavigationLink(destination: Detail(pokemon: poke)) {
                        KFImage(URL(string: "https://pokeres.bastionbot.org/images/pokemon/\(poke.url).png")!)
                            .placeholder {
                                    Image(systemName: "arrow.2.circlepath.circle")
                                        .font(.largeTitle)
                                        .opacity(0.3)
                            }
                            .cancelOnDisappear(true)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 0.3, height: 100)
                        Spacer()
                        Text(poke.name)
                            .lineLimit(1)
                            .font(.headline)
                            .padding(.trailing, 20)
                    }
                }.onDelete(perform: delete)
            }.navigationBarTitle("Pokemon List")
            .navigationBarItems(trailing: EditButton())
        }.navigationViewStyle(StackNavigationViewStyle())
    }
}

struct Detail: View {
    
    @State private var text = ""
    @State private var isFavorite = false
    var pokemon: Pokemon
    
    var body: some View {
        VStack(alignment: .center, spacing: 15) {
            HStack(alignment: .center, spacing: 10) {
                KFImage(URL(string: "https://pokeres.bastionbot.org/images/pokemon/\(pokemon.url).png")!)
                    .placeholder {
                            Image(systemName: "arrow.2.circlepath.circle")
                                .font(.largeTitle)
                                .opacity(0.3)
                    }
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width * 0.3)
                Toggle("", isOn: $isFavorite)
                .frame(width: 50)
                .padding()
            }
            Text("\(isFavorite ? "🌟" : "") \(pokemon.name) " + text)
                .font(.title)
            TextField("Enter description", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: UIScreen.main.bounds.width * 0.5)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class PokemonList: ObservableObject {
    @Published var pokemon: [Pokemon] = []
}

//MAP JSON
struct PokemonResponse: Codable {
    var pokemon: [Pokemon]
    
    enum CodingKeys: String, CodingKey {
        case pokemon = "results"
    }
}

struct Pokemon: Codable {
    var name: String
    var url: String
}
