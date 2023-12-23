using System.Collections.Generic;

namespace Core.Managers
{
    public class ManagersHolder
    {
        private readonly Dictionary<string, IManager> _managers = new Dictionary<string, IManager>();
        private static ManagersHolder _instance = null;

        public static ManagersHolder Instance
        {
            get { return _instance ??= new ManagersHolder(); }
        }

        public void AddManager(IManager manager)
        {
            var typeName =  manager.GetType().Name;
            
            if (_managers.ContainsKey(typeName))
            {
                _managers[typeName] = manager;
                return;
            }
                
            _managers.Add(typeName, manager);
        }

        public void RemoveManager(IManager manager)
        {
            var typeName = nameof(manager);
            
            if (!_managers.ContainsKey(typeName))
            {
                return;
            }

            _managers.Remove(typeName);
        }
        
        public bool GetManager<T>(out T data) where T : class
        {
            var typeName = typeof(T).Name;
            
            if (_managers.ContainsKey(typeName))
            {
                data = _managers[typeName] as T;
                return true;
            }
            
            data = null;
            return false;
        }
    }
}