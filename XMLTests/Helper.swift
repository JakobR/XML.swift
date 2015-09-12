import Foundation

private class Helper {
}

func LoadDataForResource(name: String?, withExtension ext: String?) -> NSData?
{
    guard let url = NSBundle(forClass: Helper.self).URLForResource(name, withExtension: ext) else { return nil }
    return NSData(contentsOfURL: url)
}
