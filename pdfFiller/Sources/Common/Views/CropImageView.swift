//
//  CropImageView.swift
//  pdfFiller
//
//  Created by Kostyukevich Ilya on 06.05.2022.
//

import UIKit

final class CropImageView: UIView {
    
    // MARK: Sub Types
    struct Config {
        fileprivate static let fillColor: UIColor =  #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.2)
        fileprivate static let borderColor: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 0.8)
        fileprivate static let pointColor: UIColor = #colorLiteral(red: 0.4827541662, green: 0.8517354368, blue: 1, alpha: 1)
        
        fileprivate static let borderWidth: CGFloat = 2
        fileprivate static let pointRadius: CGFloat = 5
        fileprivate static let pointActionRadius: CGFloat = 40
        fileprivate static let baseCropRectInsets: UIEdgeInsets = .zero
        
        fileprivate static let viewInsets: CGFloat = 20
    }
    
    fileprivate enum RectCorner: Int {
        case topLeft
        case topRight
        case bottomRight
        case bottomLeft
        
        var next: RectCorner {
            switch self {
            case .topLeft:
                return .topRight
            case .topRight:
                return .bottomRight
            case .bottomRight:
                return .bottomLeft
            case .bottomLeft:
                return .topLeft
            }
        }
    }
    
    // MARK: Properties
    // views
    private var sourceImageView: UIImageView = .init()
    
    // layers
    private var cropFrameLayer: CAShapeLayer = .init()
    private var cropCornerPointLayers: [CAShapeLayer] = [.init(), .init(), .init(), .init()]
    var cropPoints: [CGPoint] = []
    
    // pan gesture state
    private var panActiveCorner: RectCorner?
    
    // MARK: - Lifecycle
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialSetup()
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
                   
        guard !cropPoints.isEmpty else { return }
        
        // build frame layer
        cropFrameLayer.path = buildFramePath(cropPoints).cgPath

        // build corner point layers
        for (point, pointLayer) in zip(cropPoints, cropCornerPointLayers) {
            pointLayer.path = buildCornerPointPath(of: point)
        }
    }
        
    // MARK: Setup
    private func initialSetup() {
        translatesAutoresizingMaskIntoConstraints = false
        // image view
        sourceImageView.contentMode = .scaleAspectFit
        addSubview(sourceImageView)
        sourceImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            sourceImageView.topAnchor.constraint(equalTo: topAnchor),
            sourceImageView.rightAnchor.constraint(equalTo: rightAnchor),
            sourceImageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            sourceImageView.leftAnchor.constraint(equalTo: leftAnchor)
        ])
        
        // crop frame layer
        cropFrameLayer.fillColor = Config.fillColor.cgColor
        cropFrameLayer.strokeColor = Config.borderColor.cgColor
        cropFrameLayer.lineWidth = Config.borderWidth
        layer.addSublayer(cropFrameLayer)
        
        // crop corner point layers
        for pointLayer in cropCornerPointLayers {
            pointLayer.fillColor = Config.pointColor.cgColor
            layer.addSublayer(pointLayer)
        }
        
        // gesture
        let panGesture: UIPanGestureRecognizer = .init(target: self, action: #selector(handlePanGestureEvent))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
    }
    
    var aspectRatio: CGFloat = .zero
    
    // MARK: Input
    public func configure(image: UIImage, cropPoints: [CGPoint] = []) {
        self.sourceImageView.image = image
        
        let insets: CGFloat = Config.viewInsets
        guard let superview = superview else {
            return
        }
        
        let width: CGFloat = superview.bounds.width - (insets * 4)
        aspectRatio = width / image.size.width
        let height: CGFloat = image.size.height * aspectRatio
        
        // TODO: Нужно чистить после переиспользования
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: height),
            widthAnchor.constraint(equalToConstant: width)
        ])
                
        if cropPoints.count == 4 {
            self.cropPoints = cropPoints.map(transformForView)
        } else {
            self.cropPoints = [
                .init(x: Config.baseCropRectInsets.left, y: Config.baseCropRectInsets.top),
                .init(x: width - Config.baseCropRectInsets.right, y: Config.baseCropRectInsets.top),
                .init(x: width - Config.baseCropRectInsets.right, y: height - Config.baseCropRectInsets.bottom),
                .init(x: Config.baseCropRectInsets.left, y: height - Config.baseCropRectInsets.bottom)
            ]
        }
        
        layoutIfNeeded()
    }
    
    // MARK: Points transformations
    fileprivate func transformForView(point: CGPoint) -> CGPoint {
        return .init(x: point.x * aspectRatio, y: point.y * aspectRatio)
    }
    
    fileprivate func transformForImage(point: CGPoint) -> CGPoint {
        return .init(x: point.x / aspectRatio, y: point.y / aspectRatio)
    }
    
    // MARK: Output
    public func getFramePoints() -> [CGPoint] {
        return cropPoints.map(transformForImage)
    }
    
    public func getFramePath() -> UIBezierPath {
        let points = getFramePoints()
        return buildFramePath(points)
    }

    // MARK: Actions
    @objc func handlePanGestureEvent(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .possible:
            break
        case .began:
            break
        case .changed:
            guard let corner = panActiveCorner else {
                return
            }
            
            let location: CGPoint = gesture.location(in: self)
            cropPoints[corner: corner] = filterMovePoint(for: corner, with: location)
            cropCornerPointLayers[corner: corner].path = buildCornerPointPath(of: cropPoints[corner: corner])
            cropFrameLayer.path = buildFramePath(cropPoints).cgPath
        default:
            panActiveCorner = nil
        }
    }
    
    // MARK: Filter
    fileprivate func filterMovePoint(for corner: RectCorner, with point: CGPoint) -> CGPoint {
        var nextState = cropPoints
        nextState[corner: corner] = point
                
        // point should be in bounds of own frame
        let point: CGPoint = .init(x: min(max(point.x, 0), bounds.width),
                                   y: min(max(point.y, 0), bounds.height))
        
        var lines: [(start: CGPoint, end: CGPoint)] = []
        var cursor: RectCorner = corner
        
        // should not be collisions
        repeat {
            let next = cursor.next
            lines.append((nextState[corner: cursor], nextState[corner: next]))
            cursor = next
        } while cursor != corner
        
        
        return linesCross(start1: lines[0].start, end1: lines[0].end, start2: lines[2].start, end2: lines[2].end)
            ?? linesCross(start1: lines[1].start, end1: lines[1].end, start2: lines[3].start, end2: lines[3].end)
            ?? point
    }
        
    // MARK: Path Builders
    private func buildFramePath(_ points: [CGPoint]) -> UIBezierPath {
        let bezierPath: UIBezierPath = .init()
        bezierPath.move(to: points[corner: .topLeft])
        bezierPath.addLine(to: points[corner: .topRight])
        bezierPath.addLine(to: points[corner: .bottomRight])
        bezierPath.addLine(to: points[corner: .bottomLeft])
        bezierPath.close()
        
        return bezierPath
    }
    
    private func buildCornerPointPath(of point: CGPoint) -> CGPath {
        return UIBezierPath(arcCenter: point,
                            radius: Config.pointRadius,
                            startAngle: 0,
                            endAngle: 2 * CGFloat.pi,
                            clockwise: true).cgPath
    }
    
}

// MARK: - UIGestureRecognizerDelegate
extension CropImageView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let location: CGPoint = gestureRecognizer.location(in: self)
        let distances = cropPoints.map({ $0.distance(to: location) }).enumerated()

        guard let minItem = distances.min(by: { $0.element < $1.element }), minItem.element < Config.pointActionRadius else {
            panActiveCorner = nil
            return false
        }
        
        panActiveCorner = RectCorner(rawValue: minItem.offset)
        
        return true
    }
}

// MARK: - Math
private extension CropImageView {
    func linesCross(start1: CGPoint, end1: CGPoint, start2: CGPoint, end2: CGPoint) -> CGPoint? {
        // calculate the differences between the start and end X/Y positions for each of our points
        let delta1x = end1.x - start1.x
        let delta1y = end1.y - start1.y
        let delta2x = end2.x - start2.x
        let delta2y = end2.y - start2.y

        // create a 2D matrix from our vectors and calculate the determinant
        let determinant = delta1x * delta2y - delta2x * delta1y

        if abs(determinant) < 0.0001 {
            // if the determinant is effectively zero then the lines are parallel/colinear
            return nil
        }

        // if the coefficients both lie between 0 and 1 then we have an intersection
        let ab = ((start1.y - start2.y) * delta2x - (start1.x - start2.x) * delta2y) / determinant

        if ab > 0 && ab < 1 {
            let cd = ((start1.y - start2.y) * delta1x - (start1.x - start2.x) * delta1y) / determinant

            if cd > 0 && cd < 1 {
                // lines cross – figure out exactly where and return it
                return .init(x: start1.x + ab * delta1x,
                             y: start1.y + ab * delta1y)
            }
        }

        // lines don't cross
        return nil
    }
}

fileprivate extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }
}

// MARK: Helpers
fileprivate extension Array {
    subscript(corner corner: CropImageView.RectCorner) -> Element {
        get {
            self[corner.rawValue]
        }
        set {
            self[corner.rawValue] = newValue
        }
    }
}
