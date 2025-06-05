import UIKit
import ElixirShared
import ACT_SharedUI

final class ActivitiesListView: BaseView {

  let collectionViewLayout = updateObject(UICollectionViewFlowLayout()) {
    $0.minimumLineSpacing = 0
    $0.minimumInteritemSpacing = 0
  }

  lazy var collectionView = updateObject(UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)) {
    $0.backgroundColor = .View.Background.primary
  }

  override func setupView() {
    super.setupView()

    
  }

  override func setupSubviews() {
    super.setupSubviews()

    addSubviews(
      collectionView
    )

    collectionView.fillView(self)
  }

}


import SwiftUI

struct ContentView_Preview: PreviewProvider {
  static var previews: some View {
    BaseViewRepresentable(view: ActivitiesListView())
      .frame(width: 393, height: 852)
      .previewLayout(.fixed(width: 393, height: 852))
      .previewDisplayName("iPhone 14 Pro")
  }
}
