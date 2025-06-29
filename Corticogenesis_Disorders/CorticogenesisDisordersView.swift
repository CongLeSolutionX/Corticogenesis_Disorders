//
//MIT License
//
//Copyright © 2025 Cong Le
//
//Permission is hereby granted, free of charge, to any person obtaining a copy
//of this software and associated documentation files (the "Software"), to deal
//in the Software without restriction, including without limitation the rights
//to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//copies of the Software, and to permit persons to whom the Software is
//furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all
//copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//SOFTWARE.
//
//
//  CorticogenesisDisordersView.swift
//  Corticogenesis_Disorders
//
//  Created by Cong Le on 6/29/25.
//

import SwiftUI

// MARK: - 1. Model
// Represents the raw data structures for our application. These structs are simple,
// conform to `Identifiable` for use in SwiftUI lists, and hold the information
// about each disorder and its related genes.

/// Represents a single gene associated with a developmental disorder.
struct DisorderGene: Identifiable, Hashable {
    /// A unique identifier for the gene, typically its name.
    let id = UUID()
    /// The name of the gene, including common aliases (e.g., "LIS1 (PAFAH1B1)").
    let name: String
    /// A detailed description of the gene's function and its role in the disorder.
    let description: String
}

/// Represents a single corticogenesis disorder.
struct Disorder: Identifiable {
    /// A unique identifier for the disorder.
    let id = UUID()
    /// The scientific name of the disorder (e.g., "Lissencephaly").
    let name: String
    /// A common, more descriptive name (e.g., "Smooth Brain").
    let commonName: String
    /// The name of an SF Symbol to visually represent the disorder.
    let iconName: String
    /// The underlying cause of the disorder.
    let cause: String
    /// Common symptoms associated with the disorder.
    let symptoms: String
    /// A list of genes implicated in this disorder.
    let associatedGenes: [DisorderGene]
}

// MARK: - 2. ViewModel
// Acts as the bridge between the Model and the View. It prepares the data
// for presentation and contains the business logic. Here, it simply holds the
// static list of disorders.

/// Manages and provides the data for the CorticogenesisDisordersView.
class DisordersViewModel: ObservableObject {
    /// A published array of disorders that the SwiftUI view can subscribe to.
    /// When this array changes, the view will automatically update.
    @Published private(set) var disorders: [Disorder] = []
    
    init() {
        fetchDisorders()
    }
    
    /// Populates the `disorders` array with predefined data.
    /// In a real-world application, this data might come from a network request or a local database.
    private func fetchDisorders() {
        disorders = [
            Disorder(
                name: "Lissencephaly",
                commonName: "Smooth Brain",
                iconName: "brain.head.profile",
                cause: "A failure of proper neuronal migration during development.",
                symptoms: "The characteristic lack of normal gyri (folds) and sulci (grooves) in the brain, often leading to epilepsy and significant cognitive impairment.",
                associatedGenes: [
                    DisorderGene(name: "LIS1 (PAFAH1B1)", description: "Affects nuclear translocation and the function of dynein, a motor protein critical for intracellular transport and cell division."),
                    DisorderGene(name: "DCX (Doublecortin)", description: "A microtubule-associated protein. Mutations can cause 'double cortex' malformations where a band of grey matter is misplaced.")
                ]
            ),
            Disorder(
                name: "Tuberous Sclerosis (TSC)",
                commonName: "Tumor-Forming Disorder",
                iconName: "cross.case.fill",
                cause: "An autosomal dominant disorder resulting from the inactivation of TSC1 or TSC2 genes.",
                symptoms: "Formation of benign tumors (cortical tubers) and white matter nodes in the brain and other organs.",
                associatedGenes: [
                    DisorderGene(name: "TSC1 / TSC2", description: "Tumor suppressor genes. Their inactivation during corticogenesis leads to the growth of abnormal, disorganized tissue.")
                ]
            ),
            Disorder(
                name: "Other Genetic Links",
                commonName: "Related Ion Channel Variants",
                iconName: "link",
                cause: "Variations in genes that control fundamental cellular functions like ion transport.",
                symptoms: "Can contribute to a spectrum of cortical malformations by disrupting the electrochemical environment necessary for normal cell migration and development.",
                associatedGenes: [
                    DisorderGene(name: "SCN3A", description: "A sodium channel gene. Specific variants have been implicated in abnormal cortical folding."),
                    DisorderGene(name: "ATP1A3", description: "A Na+/K+ ATPase gene. Variations can disrupt ion balance, impacting early brain development.")
                ]
            )
        ]
    }
}

// MARK: - 3. View
// The user interface layer. These SwiftUI views are responsible for presenting
// the data provided by the `DisordersViewModel`. They are declarative, lightweight,
// and broken down into reusable components.

/// A reusable view component that displays information about a single gene.
struct GeneRowView: View {
    let gene: DisorderGene
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Gene Name
            Text(gene.name)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Gene Description
            Text(gene.description)
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
}


/// A card-like view that presents all the information for a single disorder.
struct DisorderCardView: View {
    let disorder: Disorder
    
    var body: some View {
        // `GroupBox` provides a visually distinct container for each disorder.
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                // MARK: Header
                HStack(spacing: 12) {
                    Image(systemName: disorder.iconName)
                        .font(.title)
                        .foregroundColor(.accentColor)
                        .frame(width: 40)
                        .accessibilityLabel(Text("Icon for \(disorder.name)"))

                    VStack(alignment: .leading) {
                        Text(disorder.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(disorder.commonName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Divider()
                
                // MARK: Details Section
                InfoRow(title: "Cause", content: disorder.cause)
                InfoRow(title: "Symptoms", content: disorder.symptoms)

                // MARK: Associated Genes Section
                if !disorder.associatedGenes.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Associated Genes")
                            .font(.headline)
                        
                        // Loop through each gene to create a GeneRowView.
                        ForEach(disorder.associatedGenes, id: \.self) { gene in
                            GeneRowView(gene: gene)
                        }
                    }
                    .padding(.top, 8)
                }
            }
        }
    }
}

/// A helper view to consistently display a title and content.
struct InfoRow: View {
    let title: String
    let content: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            Text(content)
                .font(.body)
                .foregroundColor(.secondary)
        }
    }
}

/// The main view of the application, displaying a list of corticogenesis disorders.
struct CorticogenesisDisordersView: View {
    /// The source of truth for the view's data.
    /// `@StateObject` ensures the ViewModel is created once and kept alive for the
    /// lifecycle of the view.
    @StateObject private var viewModel = DisordersViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Header providing context to the user.
                    Text("Errors in the complex process of corticogenesis can lead to severe neurological disorders, often caused by mutations in genes that control neuronal migration.")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                    
                    // Creates a `DisorderCardView` for each disorder in the view model.
                    ForEach(viewModel.disorders) { disorder in
                        DisorderCardView(disorder: disorder)
                    }
                }
                .padding()
            }
            .navigationTitle("Developmental Disorders")
        }
    }
}

// MARK: - 4. Preview
// Provides a preview of the view in Xcode, allowing for rapid UI development
// without running the full application on a simulator or device.

struct CorticogenesisDisordersView_Previews: PreviewProvider {
    static var previews: some View {
        CorticogenesisDisordersView()
            // Preview in both light and dark modes for testing.
            .preferredColorScheme(.light)
        
        CorticogenesisDisordersView()
            .preferredColorScheme(.dark)
    }
}
