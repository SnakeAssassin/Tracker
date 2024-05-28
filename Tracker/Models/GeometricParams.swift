import UIKit

struct GeometricParams {
    let cellCount: Int                  // Количество ячеек
    let topInset: CGFloat               // Отступ сверху
    let bottomInset: CGFloat            // Отступ снизу
    let leftInset: CGFloat              // Отступ слева
    let rightInset: CGFloat             // Отступ справа
    let cellSpacingVertical: CGFloat    // Минимальный отступ между ячейками по вертикали
    let cellSpacingHorizontal: CGFloat  // Минимальный отступ между ячейками по горизонтали
    let size: CGSize                    // Фиксированный размер ячейки
    let paddingWidth: CGFloat           // Расчетная ширина ячейки
    
    init(cellCount: Int, topInset: CGFloat, bottomInset: CGFloat, leftInset: CGFloat, rightInset: CGFloat, cellSpacingHorizontal: CGFloat, cellSpacingVertical: CGFloat, size: CGSize) {
        self.cellCount = cellCount
        self.topInset = topInset
        self.bottomInset = bottomInset
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.cellSpacingVertical = cellSpacingVertical
        self.cellSpacingHorizontal = cellSpacingHorizontal
        self.size = size
        self.paddingWidth = leftInset + rightInset + CGFloat(cellCount - 1) * cellSpacingHorizontal
    }
}
